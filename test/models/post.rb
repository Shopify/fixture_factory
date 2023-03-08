# frozen_string_literal: true

class Post < FakeRecord::Base
  attributes :title, :body, :active, :number
end
