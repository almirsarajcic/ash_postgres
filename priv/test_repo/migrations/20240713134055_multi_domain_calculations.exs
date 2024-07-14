defmodule AshPostgres.TestRepo.Migrations.MultiDomainCalculations do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:sub_items, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("uuid_generate_v7()"), primary_key: true)
      add(:amount, :bigint, null: false)

      add(:inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(:updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(:other_item_id, :uuid, null: false)
    end

    create table(:other_items, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("uuid_generate_v7()"), primary_key: true)
    end

    alter table(:sub_items) do
      modify(
        :other_item_id,
        references(:other_items,
          column: :id,
          name: "sub_items_other_item_id_fkey",
          type: :uuid,
          prefix: "public",
          on_delete: :delete_all
        )
      )
    end

    create(index(:sub_items, [:other_item_id]))

    alter table(:other_items) do
      add(:inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(:updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(:item_id, :uuid, null: false)
    end

    create table(:items, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("uuid_generate_v7()"), primary_key: true)
    end

    alter table(:other_items) do
      modify(
        :item_id,
        references(:items,
          column: :id,
          name: "other_items_item_id_fkey",
          type: :uuid,
          prefix: "public",
          on_delete: :delete_all
        )
      )
    end

    create(index(:other_items, [:item_id]))

    alter table(:items) do
      add(:inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(:updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )
    end
  end

  def down do
    alter table(:items) do
      remove(:updated_at)
      remove(:inserted_at)
    end

    drop_if_exists(index(:other_items, [:item_id]))

    drop(constraint(:other_items, "other_items_item_id_fkey"))

    alter table(:other_items) do
      modify(:item_id, :uuid)
    end

    drop(table(:items))

    alter table(:other_items) do
      remove(:item_id)
      remove(:updated_at)
      remove(:inserted_at)
    end

    drop_if_exists(index(:sub_items, [:other_item_id]))

    drop(constraint(:sub_items, "sub_items_other_item_id_fkey"))

    alter table(:sub_items) do
      modify(:other_item_id, :uuid)
    end

    drop(table(:other_items))

    drop(table(:sub_items))
  end
end