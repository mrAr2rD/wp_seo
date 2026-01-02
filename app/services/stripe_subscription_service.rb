class StripeSubscriptionService
  attr_reader :user, :params, :subscription, :error_message

  def initialize(user, params = {})
    @user = user
    @params = params
    @error_message = nil
  end

  def create
    plan = Plan.find(params[:plan_id])

    begin
      # Create or retrieve Stripe customer
      customer = get_or_create_stripe_customer

      # Create Stripe subscription
      stripe_subscription = Stripe::Subscription.create(
        customer: customer.id,
        items: [{ price: plan.stripe_price_id }],
        payment_behavior: 'default_incomplete',
        expand: ['latest_invoice.payment_intent']
      )

      # Create local subscription record
      @subscription = user.create_subscription(
        plan: plan,
        stripe_subscription_id: stripe_subscription.id,
        status: stripe_subscription.status,
        current_period_end: Time.at(stripe_subscription.current_period_end)
      )

      true
    rescue Stripe::StripeError => e
      @error_message = e.message
      false
    end
  end

  def update
    return false unless user.subscription

    plan = Plan.find(params[:plan_id])

    begin
      stripe_subscription = Stripe::Subscription.update(
        user.subscription.stripe_subscription_id,
        items: [{
          id: Stripe::Subscription.retrieve(user.subscription.stripe_subscription_id).items.data[0].id,
          price: plan.stripe_price_id
        }]
      )

      user.subscription.update(
        plan: plan,
        status: stripe_subscription.status,
        current_period_end: Time.at(stripe_subscription.current_period_end)
      )

      @subscription = user.subscription
      true
    rescue Stripe::StripeError => e
      @error_message = e.message
      false
    end
  end

  def cancel
    return false unless user.subscription

    begin
      Stripe::Subscription.delete(user.subscription.stripe_subscription_id)
      user.subscription.update(status: 'canceled')
      true
    rescue Stripe::StripeError => e
      @error_message = e.message
      false
    end
  end

  private

  def get_or_create_stripe_customer
    if user.stripe_customer_id.present?
      Stripe::Customer.retrieve(user.stripe_customer_id)
    else
      customer = Stripe::Customer.create(
        email: user.email,
        name: user.name,
        source: params[:stripe_token]
      )
      user.update(stripe_customer_id: customer.id)
      customer
    end
  end
end
