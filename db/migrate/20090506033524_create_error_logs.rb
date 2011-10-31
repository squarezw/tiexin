class CreateErrorLogs < ActiveRecord::Migration
  def self.up
    create_table :error_logs do |t|
      t.integer :member_id
      t.text :request_uri
      t.text :http_headers
      t.text :parameters
      t.text :error_messages
      t.text :stack_trace
      t.timestamps
    end
  end

  def self.down
    drop_table :error_logs
  end
end
