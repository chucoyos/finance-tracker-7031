class Stock < ApplicationRecord
	after_create_commit { broadcast_prepend_to 'stocks' }
	after_update_commit { broadcast_replace_to 'stocks' }
	after_destroy_commit { broadcast_remove_to 'stocks' }

	def self.new_lookup(ticker_symbol)
		client =
			IEX::Api::Client.new(
				publishable_token:
					Rails.application.credentials.iex_client[:sandbox_api_key],
				secret_token: 'secret_token',
				endpoint: 'https://sandbox.iexapis.com/v1'
			)
		begin
			new(
				ticker: ticker_symbol,
				name: client.company(ticker_symbol).company_name,
				last_price: client.price(ticker_symbol)
			)
		rescue => exception
			return nil
		end
	end
end
