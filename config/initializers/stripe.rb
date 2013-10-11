Rails.configuration.stripe = {
    :publishable_key => 'pk_test_XFXGKFgaQPxBgaAB4nf8xxRK',
    :secret_key      => 'sk_test_N3MlhMVutaL7O42p3mqu4J43'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]