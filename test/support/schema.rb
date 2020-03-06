# frozen_string_literal: true

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:",
)

ActiveRecord::Schema.define do
  create_table(:users) do |t|
    t.string(:email)
    t.string(:name)
    t.boolean(:locked)
    t.json(:settings)
  end

  create_table(:accounts) do |t|
    t.string(:plan)
    t.string(:company)
    t.references(:user)
  end
end
