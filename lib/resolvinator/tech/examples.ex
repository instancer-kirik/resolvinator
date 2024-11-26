defmodule Resolvinator.Tech.Examples do
  alias Resolvinator.Tech

  @doc """
  Example usage of the Tech context.
  """
  def run_examples do
    # Create a part
    {:ok, microphone} = Tech.create_tech_part(%{
      name: "SM58 Microphone",
      description: "Professional dynamic vocal microphone",
      part_number: "SM58-LC",
      category: "audio",
      manufacturer: "Shure",
      cost: Decimal.new("99.00"),
      quantity: 5,
      min_quantity: 2,
      location: "Warehouse A",
      specifications: %{
        "type" => "dynamic",
        "frequency_response" => "50 to 15,000 Hz",
        "impedance" => "300 ohms"
      }
    })

    # List parts with low stock
    low_stock_parts = Tech.list_tech_parts(
      filters: %{
        quantity_below_min: true
      }
    )

    # Update part quantity
    {:ok, updated_part} = Tech.update_tech_part(microphone, %{
      quantity: 10
    })

    # List parts from a specific supplier
    supplier_parts = Tech.list_tech_parts(
      filters: %{
        supplier_id: 1
      }
    )

    # Create a tech item
    {:ok, mixer} = Tech.create_tech_item(%{
      name: "X32 Digital Mixer",
      description: "Professional 32-channel digital mixing console",
      category: "audio",
      status: "available",
      manufacturer: "Behringer",
      model: "X32",
      serial_number: "X32-2023-001",
      purchase_date: ~D[2023-01-15],
      warranty_expiry: ~D[2025-01-15],
      specifications: %{
        "channels" => 32,
        "aux_sends" => 16,
        "effects" => ["reverb", "delay", "compression"]
      },
      maintenance_history: [
        %{
          "date" => "2023-06-15",
          "type" => "firmware_update",
          "description" => "Updated to firmware v4.0"
        }
      ]
    })

    # Update item status and add maintenance record
    {:ok, updated_mixer} = Tech.update_tech_item(mixer, %{
      status: "maintenance",
      maintenance_history: [
        %{
          "date" => "2023-12-01",
          "type" => "repair",
          "description" => "Replaced faulty fader on channel 1"
        }
        | mixer.maintenance_history
      ]
    })

    # Create a kit
    {:ok, mic_kit} = Tech.create_tech_kit(%{
      name: "Vocal Performance Kit",
      description: "Complete vocal performance setup",
      kit_number: "VPK-001",
      category: "audio",
      status: "available",
      location: "Storage Room B",
      contents: [
        %{
          "item_id" => mixer.id,
          "quantity" => 1,
          "notes" => "Main mixer"
        }
      ],
      assembly_instructions: "1. Set up mixer on stable surface\n2. Connect microphones\n3. Test levels",
      notes: "Suitable for small to medium venues"
    })

    # Update kit status and contents
    {:ok, updated_kit} = Tech.update_tech_kit(mic_kit, %{
      status: "in_use",
      location: "Stage A"
    })

    # Create technical documentation
    {:ok, manual} = Tech.create_tech_documentation(%{
      title: "X32 Setup Guide",
      description: "Comprehensive setup guide for X32 Digital Mixer",
      content: """
      # X32 Digital Mixer Setup Guide

      This guide covers the basic setup and configuration of the X32 Digital Mixer.

      ## Initial Setup
      1. Power connection
      2. Audio connections
      3. Network setup

      ## Basic Configuration
      - Channel setup
      - Routing
      - Effects configuration
      """,
      doc_type: "guide",
      version: "1.0",
      author: "Technical Team",
      tags: ["audio", "mixer", "setup"],
      metadata: %{
        "difficulty" => "intermediate",
        "time_estimate" => "30 minutes"
      }
    })

    # Search examples
    items = Tech.list_tech_items(
      filters: %{
        search: "microphone"
      }
    )

    parts = Tech.list_tech_parts(
      filters: %{
        search: "cable"
      }
    )

    kits = Tech.list_tech_kits(
      filters: %{
        search: "vocal"
      }
    )

    docs = Tech.list_tech_documentation(
      filters: %{
        search: "setup guide"
      }
    )
  end
end
