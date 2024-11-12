defmodule Resolvinator.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :username, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :is_admin, :boolean, default: false
    field :confirmed_at, :naive_datetime
    field :preferences, :map, default: %{}
    field :status, :string, default: "active"
    field :banned_at, :naive_datetime

    # Content created by this user
    has_many :created_problems, Resolvinator.Content.Problem, foreign_key: :creator_id
    has_many :created_solutions, Resolvinator.Content.Solution, foreign_key: :creator_id
    has_many :created_advantages, Resolvinator.Content.Advantage, foreign_key: :creator_id
    has_many :created_lessons, Resolvinator.Content.Lesson, foreign_key: :creator_id

    # Content associated with this user
    many_to_many :problems_experienced, Resolvinator.Content.Problem,
      join_through: "user_problems"
    many_to_many :solutions_used, Resolvinator.Content.Solution,
      join_through: "user_solutions"
    many_to_many :advantages_experienced, Resolvinator.Content.Advantage,
      join_through: "user_advantages"
    many_to_many :lessons_learned, Resolvinator.Content.Lesson,
      join_through: "user_lessons"

    # Hidden content tracking
    many_to_many :hidden_descriptions, Resolvinator.Content.Description,
      join_through: "user_hidden_descriptions"

    many_to_many :inventory_items, Resolvinator.Resources.InventoryItems.InventoryItem,
      join_through: "user_inventories",
      join_keys: [user_id: :id, inventory_item_id: :id],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :is_admin, :preferences, :status])
    |> validate_required([:email, :username])
    |> validate_email([])
    |> validate_username()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    # Convert string keys to atoms if needed
    attrs = for {key, val} <- attrs, into: %{} do
      if is_binary(key), do: {String.to_existing_atom(key), val}, else: {key, val}
    end

    user
    |> cast(attrs, [:email, :username, :password, :is_admin])
    |> validate_required([:email, :username, :password])
    |> validate_email([])
    |> validate_username()
    |> validate_password([])
    |> maybe_hash_password([])
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_.-]+$/, message: "can only contain letters, numbers, and _.-")
    |> unique_constraint(:username)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Resolvinator.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Resolvinator.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and is_binary(password) do
    IO.inspect(password, label: "Checking password")
    IO.inspect(hashed_password, label: "Against hash")
    result = Bcrypt.verify_pass(password, hashed_password)
    IO.inspect(result, label: "Password verification result")
    result
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc """
  Changeset for username updates
  """
  def username_changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_username()
  end


  @doc """
  Changeset for banning users
  """
  def ban_changeset(user, attrs) do
    user
    |> cast(attrs, [:banned_at, :status])
    |> put_change(:status, "banned")
  end

  @doc """
  Changeset for updating user preferences
  """
  def preferences_changeset(user, attrs) do
    user
    |> cast(attrs, [:preferences])
    |> validate_required([:preferences])
  end
end
