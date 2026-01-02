class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :name, :created_at

  attribute :subscription_status do |user|
    user.subscription&.status || "none"
  end

  attribute :subscription_plan do |user|
    user.subscription&.plan&.name
  end
end
