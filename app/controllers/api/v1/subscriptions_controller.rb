module Api
  module V1
    class SubscriptionsController < BaseController
      def index
        @subscription = current_api_v1_user.subscription
        render json: @subscription
      end

      def create
        service = StripeSubscriptionService.new(current_api_v1_user, subscription_params)

        if service.create
          render json: { subscription: service.subscription, message: 'Subscription created successfully' }, status: :created
        else
          render_error(service.error_message)
        end
      end

      def update
        service = StripeSubscriptionService.new(current_api_v1_user, subscription_params)

        if service.update
          render json: { subscription: service.subscription, message: 'Subscription updated successfully' }
        else
          render_error(service.error_message)
        end
      end

      def destroy
        service = StripeSubscriptionService.new(current_api_v1_user)

        if service.cancel
          render json: { message: 'Subscription canceled successfully' }
        else
          render_error(service.error_message)
        end
      end

      def webhook
        # Handle Stripe webhooks
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']

        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
          )

          case event.type
          when 'customer.subscription.updated', 'customer.subscription.deleted'
            subscription = event.data.object
            update_subscription_from_stripe(subscription)
          end

          render json: { received: true }
        rescue JSON::ParserError, Stripe::SignatureVerificationError => e
          render json: { error: e.message }, status: :bad_request
        end
      end

      private

      def subscription_params
        params.require(:subscription).permit(:plan_id, :stripe_token)
      end

      def update_subscription_from_stripe(stripe_subscription)
        subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
        return unless subscription

        subscription.update(
          status: stripe_subscription.status,
          current_period_end: Time.at(stripe_subscription.current_period_end)
        )
      end
    end
  end
end
