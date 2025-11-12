class CreateEventsAndVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.text :description
      t.string :image_url
      t.string :registration_link
      t.boolean :published, default: true
      t.timestamps
    end

    create_table :event_times do |t|
      t.references :event, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :event_times, [:event_id, :position]

    create_table :event_versions do |t|
      t.references :event, null: false, foreign_key: true
      t.string :event_name
      t.string :event_location
      t.text :event_description
      t.string :event_image_url
      t.string :event_registration_link
      t.json :event_times_snapshot
      t.string :action_type # 'create', 'update', 'delete'
      t.string :changed_by # username or admin identifier
      t.text :change_summary
      t.datetime :version_timestamp
      t.timestamps
    end

    add_index :event_versions, [:event_id, :created_at]
    add_index :event_versions, :version_timestamp
  end
end
