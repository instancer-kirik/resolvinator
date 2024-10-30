defmodule Resolvinator.RisksTest do
  use Resolvinator.DataCase

  alias Resolvinator.Risks

  describe "risk_categories" do
    alias Resolvinator.Risks.Category

    import Resolvinator.RisksFixtures

    @invalid_attrs %{name: nil, description: nil, color: nil, assessment_criteria: nil}

    test "list_risk_categories/0 returns all risk_categories" do
      category = category_fixture()
      assert Risks.list_risk_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Risks.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", color: "some color", assessment_criteria: %{}}

      assert {:ok, %Category{} = category} = Risks.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.color == "some color"
      assert category.assessment_criteria == %{}
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Risks.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", color: "some updated color", assessment_criteria: %{}}

      assert {:ok, %Category{} = category} = Risks.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.color == "some updated color"
      assert category.assessment_criteria == %{}
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Risks.update_category(category, @invalid_attrs)
      assert category == Risks.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Risks.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Risks.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Risks.change_category(category)
    end
  end

  describe "risks" do
    alias Resolvinator.Risks.Risk

    import Resolvinator.RisksFixtures

    @invalid_attrs %{name: nil, priority: nil, status: nil, description: nil, probability: nil, impact: nil, mitigation_status: nil, detection_date: nil, review_date: nil}

    test "list_risks/0 returns all risks" do
      risk = risk_fixture()
      assert Risks.list_risks() == [risk]
    end

    test "get_risk!/1 returns the risk with given id" do
      risk = risk_fixture()
      assert Risks.get_risk!(risk.id) == risk
    end

    test "create_risk/1 with valid data creates a risk" do
      valid_attrs = %{name: "some name", priority: "some priority", status: "some status", description: "some description", probability: "some probability", impact: "some impact", mitigation_status: "some mitigation_status", detection_date: ~D[2024-10-29], review_date: ~D[2024-10-29]}

      assert {:ok, %Risk{} = risk} = Risks.create_risk(valid_attrs)
      assert risk.name == "some name"
      assert risk.priority == "some priority"
      assert risk.status == "some status"
      assert risk.description == "some description"
      assert risk.probability == "some probability"
      assert risk.impact == "some impact"
      assert risk.mitigation_status == "some mitigation_status"
      assert risk.detection_date == ~D[2024-10-29]
      assert risk.review_date == ~D[2024-10-29]
    end

    test "create_risk/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Risks.create_risk(@invalid_attrs)
    end

    test "update_risk/2 with valid data updates the risk" do
      risk = risk_fixture()
      update_attrs = %{name: "some updated name", priority: "some updated priority", status: "some updated status", description: "some updated description", probability: "some updated probability", impact: "some updated impact", mitigation_status: "some updated mitigation_status", detection_date: ~D[2024-10-30], review_date: ~D[2024-10-30]}

      assert {:ok, %Risk{} = risk} = Risks.update_risk(risk, update_attrs)
      assert risk.name == "some updated name"
      assert risk.priority == "some updated priority"
      assert risk.status == "some updated status"
      assert risk.description == "some updated description"
      assert risk.probability == "some updated probability"
      assert risk.impact == "some updated impact"
      assert risk.mitigation_status == "some updated mitigation_status"
      assert risk.detection_date == ~D[2024-10-30]
      assert risk.review_date == ~D[2024-10-30]
    end

    test "update_risk/2 with invalid data returns error changeset" do
      risk = risk_fixture()
      assert {:error, %Ecto.Changeset{}} = Risks.update_risk(risk, @invalid_attrs)
      assert risk == Risks.get_risk!(risk.id)
    end

    test "delete_risk/1 deletes the risk" do
      risk = risk_fixture()
      assert {:ok, %Risk{}} = Risks.delete_risk(risk)
      assert_raise Ecto.NoResultsError, fn -> Risks.get_risk!(risk.id) end
    end

    test "change_risk/1 returns a risk changeset" do
      risk = risk_fixture()
      assert %Ecto.Changeset{} = Risks.change_risk(risk)
    end
  end

  describe "impacts" do
    alias Resolvinator.Risks.Impact

    import Resolvinator.RisksFixtures

    @invalid_attrs %{description: nil, severity: nil, area: nil, likelihood: nil, estimated_cost: nil, timeframe: nil, notes: nil}

    test "list_impacts/0 returns all impacts" do
      impact = impact_fixture()
      assert Risks.list_impacts() == [impact]
    end

    test "get_impact!/1 returns the impact with given id" do
      impact = impact_fixture()
      assert Risks.get_impact!(impact.id) == impact
    end

    test "create_impact/1 with valid data creates a impact" do
      valid_attrs = %{description: "some description", severity: "some severity", area: "some area", likelihood: "some likelihood", estimated_cost: "120.5", timeframe: "some timeframe", notes: "some notes"}

      assert {:ok, %Impact{} = impact} = Risks.create_impact(valid_attrs)
      assert impact.description == "some description"
      assert impact.severity == "some severity"
      assert impact.area == "some area"
      assert impact.likelihood == "some likelihood"
      assert impact.estimated_cost == Decimal.new("120.5")
      assert impact.timeframe == "some timeframe"
      assert impact.notes == "some notes"
    end

    test "create_impact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Risks.create_impact(@invalid_attrs)
    end

    test "update_impact/2 with valid data updates the impact" do
      impact = impact_fixture()
      update_attrs = %{description: "some updated description", severity: "some updated severity", area: "some updated area", likelihood: "some updated likelihood", estimated_cost: "456.7", timeframe: "some updated timeframe", notes: "some updated notes"}

      assert {:ok, %Impact{} = impact} = Risks.update_impact(impact, update_attrs)
      assert impact.description == "some updated description"
      assert impact.severity == "some updated severity"
      assert impact.area == "some updated area"
      assert impact.likelihood == "some updated likelihood"
      assert impact.estimated_cost == Decimal.new("456.7")
      assert impact.timeframe == "some updated timeframe"
      assert impact.notes == "some updated notes"
    end

    test "update_impact/2 with invalid data returns error changeset" do
      impact = impact_fixture()
      assert {:error, %Ecto.Changeset{}} = Risks.update_impact(impact, @invalid_attrs)
      assert impact == Risks.get_impact!(impact.id)
    end

    test "delete_impact/1 deletes the impact" do
      impact = impact_fixture()
      assert {:ok, %Impact{}} = Risks.delete_impact(impact)
      assert_raise Ecto.NoResultsError, fn -> Risks.get_impact!(impact.id) end
    end

    test "change_impact/1 returns a impact changeset" do
      impact = impact_fixture()
      assert %Ecto.Changeset{} = Risks.change_impact(impact)
    end
  end

  describe "mitigations" do
    alias Resolvinator.Risks.Mitigation

    import Resolvinator.RisksFixtures

    @invalid_attrs %{status: nil, description: nil, strategy: nil, effectiveness: nil, cost: nil, start_date: nil, target_date: nil, completion_date: nil, notes: nil}

    test "list_mitigations/0 returns all mitigations" do
      mitigation = mitigation_fixture()
      assert Risks.list_mitigations() == [mitigation]
    end

    test "get_mitigation!/1 returns the mitigation with given id" do
      mitigation = mitigation_fixture()
      assert Risks.get_mitigation!(mitigation.id) == mitigation
    end

    test "create_mitigation/1 with valid data creates a mitigation" do
      valid_attrs = %{status: "some status", description: "some description", strategy: "some strategy", effectiveness: "some effectiveness", cost: "120.5", start_date: ~D[2024-10-29], target_date: ~D[2024-10-29], completion_date: ~D[2024-10-29], notes: "some notes"}

      assert {:ok, %Mitigation{} = mitigation} = Risks.create_mitigation(valid_attrs)
      assert mitigation.status == "some status"
      assert mitigation.description == "some description"
      assert mitigation.strategy == "some strategy"
      assert mitigation.effectiveness == "some effectiveness"
      assert mitigation.cost == Decimal.new("120.5")
      assert mitigation.start_date == ~D[2024-10-29]
      assert mitigation.target_date == ~D[2024-10-29]
      assert mitigation.completion_date == ~D[2024-10-29]
      assert mitigation.notes == "some notes"
    end

    test "create_mitigation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Risks.create_mitigation(@invalid_attrs)
    end

    test "update_mitigation/2 with valid data updates the mitigation" do
      mitigation = mitigation_fixture()
      update_attrs = %{status: "some updated status", description: "some updated description", strategy: "some updated strategy", effectiveness: "some updated effectiveness", cost: "456.7", start_date: ~D[2024-10-30], target_date: ~D[2024-10-30], completion_date: ~D[2024-10-30], notes: "some updated notes"}

      assert {:ok, %Mitigation{} = mitigation} = Risks.update_mitigation(mitigation, update_attrs)
      assert mitigation.status == "some updated status"
      assert mitigation.description == "some updated description"
      assert mitigation.strategy == "some updated strategy"
      assert mitigation.effectiveness == "some updated effectiveness"
      assert mitigation.cost == Decimal.new("456.7")
      assert mitigation.start_date == ~D[2024-10-30]
      assert mitigation.target_date == ~D[2024-10-30]
      assert mitigation.completion_date == ~D[2024-10-30]
      assert mitigation.notes == "some updated notes"
    end

    test "update_mitigation/2 with invalid data returns error changeset" do
      mitigation = mitigation_fixture()
      assert {:error, %Ecto.Changeset{}} = Risks.update_mitigation(mitigation, @invalid_attrs)
      assert mitigation == Risks.get_mitigation!(mitigation.id)
    end

    test "delete_mitigation/1 deletes the mitigation" do
      mitigation = mitigation_fixture()
      assert {:ok, %Mitigation{}} = Risks.delete_mitigation(mitigation)
      assert_raise Ecto.NoResultsError, fn -> Risks.get_mitigation!(mitigation.id) end
    end

    test "change_mitigation/1 returns a mitigation changeset" do
      mitigation = mitigation_fixture()
      assert %Ecto.Changeset{} = Risks.change_mitigation(mitigation)
    end
  end

  describe "mitigation_tasks" do
    alias Resolvinator.Risks.MitigationTask

    import Resolvinator.RisksFixtures

    @invalid_attrs %{name: nil, status: nil, description: nil, due_date: nil, completion_date: nil}

    test "list_mitigation_tasks/0 returns all mitigation_tasks" do
      mitigation_task = mitigation_task_fixture()
      assert Risks.list_mitigation_tasks() == [mitigation_task]
    end

    test "get_mitigation_task!/1 returns the mitigation_task with given id" do
      mitigation_task = mitigation_task_fixture()
      assert Risks.get_mitigation_task!(mitigation_task.id) == mitigation_task
    end

    test "create_mitigation_task/1 with valid data creates a mitigation_task" do
      valid_attrs = %{name: "some name", status: "some status", description: "some description", due_date: ~D[2024-10-29], completion_date: ~D[2024-10-29]}

      assert {:ok, %MitigationTask{} = mitigation_task} = Risks.create_mitigation_task(valid_attrs)
      assert mitigation_task.name == "some name"
      assert mitigation_task.status == "some status"
      assert mitigation_task.description == "some description"
      assert mitigation_task.due_date == ~D[2024-10-29]
      assert mitigation_task.completion_date == ~D[2024-10-29]
    end

    test "create_mitigation_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Risks.create_mitigation_task(@invalid_attrs)
    end

    test "update_mitigation_task/2 with valid data updates the mitigation_task" do
      mitigation_task = mitigation_task_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", description: "some updated description", due_date: ~D[2024-10-30], completion_date: ~D[2024-10-30]}

      assert {:ok, %MitigationTask{} = mitigation_task} = Risks.update_mitigation_task(mitigation_task, update_attrs)
      assert mitigation_task.name == "some updated name"
      assert mitigation_task.status == "some updated status"
      assert mitigation_task.description == "some updated description"
      assert mitigation_task.due_date == ~D[2024-10-30]
      assert mitigation_task.completion_date == ~D[2024-10-30]
    end

    test "update_mitigation_task/2 with invalid data returns error changeset" do
      mitigation_task = mitigation_task_fixture()
      assert {:error, %Ecto.Changeset{}} = Risks.update_mitigation_task(mitigation_task, @invalid_attrs)
      assert mitigation_task == Risks.get_mitigation_task!(mitigation_task.id)
    end

    test "delete_mitigation_task/1 deletes the mitigation_task" do
      mitigation_task = mitigation_task_fixture()
      assert {:ok, %MitigationTask{}} = Risks.delete_mitigation_task(mitigation_task)
      assert_raise Ecto.NoResultsError, fn -> Risks.get_mitigation_task!(mitigation_task.id) end
    end

    test "change_mitigation_task/1 returns a mitigation_task changeset" do
      mitigation_task = mitigation_task_fixture()
      assert %Ecto.Changeset{} = Risks.change_mitigation_task(mitigation_task)
    end
  end
end
