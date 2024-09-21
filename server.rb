require 'stripe'
require 'sinatra'
require 'sinatra/cross_origin'

# Set your Stripe secret key from environment variable
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :port, 4242

YOUR_DOMAIN = 'https://universitysuperleague.com'

# Enable Cross-Origin Requests (CORS)
configure do
  enable :cross_origin
end

# Set up CORS headers before each request
before do
  response.headers['Access-Control-Allow-Origin'] = 'https://universitysuperleague.com'
  response.headers['Access-Control-Allow-Methods'] = ['GET', 'POST', 'OPTIONS']
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
end

# Handle OPTIONS requests (CORS preflight requests)
options "*" do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Content-Type"
  response.headers["Access-Control-Allow-Origin"] = 'https://universitysuperleague.com'
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
  200
end

# Root route to check if the server is running
get '/' do
  'Backend is running!'
end

# POST route to create Stripe checkout session
post '/create-checkout-session' do
  content_type 'application/json'

  begin
    # Log for debugging
    puts "Creating Stripe Checkout session..."

    session = Stripe::Checkout::Session.create({
      line_items: [{
        price: 'prod_QoSzuovFVHvLTA', # Replace with actual price ID
        quantity: 1,
      }],
      mode: 'payment',
      success_url: "#{YOUR_DOMAIN}/success.html",
      cancel_url: "#{YOUR_DOMAIN}/cancel.html",
    })

    # Log success
    puts "Checkout session created: #{session.url}"

    # Return the session URL as JSON
    { url: session.url }.to_json
  rescue Stripe::StripeError => e
    # Log Stripe-specific errors
    puts "Stripe error: #{e.message}"
    status 500
    { error: "Stripe error: #{e.message}" }.to_json
  rescue => e
    # Log all other errors
    puts "Server error: #{e.message}"
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end
