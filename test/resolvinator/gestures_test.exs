defmodule Resolvinator.GesturesTest do
  use Resolvinator.DataCase

  alias Resolvinator.Gestures

  describe "gestures" do
    alias Resolvinator.Gestures.Gesture

    import Resolvinator.GesturesFixtures

    @invalid_attrs %{name: nil, description: nil, svg: nil, fingers: nil}

    test "list_gestures/0 returns all gestures" do
      gesture = gesture_fixture()
      assert Gestures.list_gestures() == [gesture]
    end

    test "get_gesture!/1 returns the gesture with given id" do
      gesture = gesture_fixture()
      assert Gestures.get_gesture!(gesture.id) == gesture
    end

    test "create_gesture/1 with valid data creates a gesture" do
      valid_attrs = %{name: "some name", description: "some description", svg: "some svg", fingers: "some fingers"}

      assert {:ok, %Gesture{} = gesture} = Gestures.create_gesture(valid_attrs)
      assert gesture.name == "some name"
      assert gesture.description == "some description"
      assert gesture.svg == "some svg"
      assert gesture.fingers == "some fingers"
    end

    test "create_gesture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gestures.create_gesture(@invalid_attrs)
    end

    test "update_gesture/2 with valid data updates the gesture" do
      gesture = gesture_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", svg: "some updated svg", fingers: "some updated fingers"}

      assert {:ok, %Gesture{} = gesture} = Gestures.update_gesture(gesture, update_attrs)
      assert gesture.name == "some updated name"
      assert gesture.description == "some updated description"
      assert gesture.svg == "some updated svg"
      assert gesture.fingers == "some updated fingers"
    end

    test "update_gesture/2 with invalid data returns error changeset" do
      gesture = gesture_fixture()
      assert {:error, %Ecto.Changeset{}} = Gestures.update_gesture(gesture, @invalid_attrs)
      assert gesture == Gestures.get_gesture!(gesture.id)
    end

    test "delete_gesture/1 deletes the gesture" do
      gesture = gesture_fixture()
      assert {:ok, %Gesture{}} = Gestures.delete_gesture(gesture)
      assert_raise Ecto.NoResultsError, fn -> Gestures.get_gesture!(gesture.id) end
    end

    test "change_gesture/1 returns a gesture changeset" do
      gesture = gesture_fixture()
      assert %Ecto.Changeset{} = Gestures.change_gesture(gesture)
    end
  end
end
