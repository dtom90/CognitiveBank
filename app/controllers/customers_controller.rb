class CustomersController < ApplicationController
  before_action :logged_in_user
  
  def profile
    if is_customer?
      
      # Sort transaction categories
      # cc = {}
      # TransactionCategory.all.each do |category|
      #   cc[category.name] = current_customer.transactions.where(transaction_category: category).count
      # end
      # @sorted_categories = cc.sort_by {|k,v| v}.reverse.to_h
      
      puts "Customer #{current_customer.user.name} logged in!"

      puts 'Customer Profile:'
      current_customer.attributes.except('id', 'context').each do |k,v|
        puts "  #{Customer.human_attribute_name k}: #{v}"
      end
      
      puts 'Fetching churn probability...'
      
      # Get churn
      if Rails.env.production?
        @churn = current_customer.get_churn
      else
        puts 'Sending to churn scoring: '+current_customer.churn_attrs.values.to_s
        @churn = current_customer.load_sample_ml_result
      end
      
      puts 'Customer churn result: '
      @churn.each do |k,v|
        puts "  #{k.to_s.humanize}: #{v}"
      end
      
      puts "Fetching Personality Insights for #{current_customer.user.name}..."
      
      # get personality
      @twitter = current_customer.twitter_personality
      
      puts 'Customer Personality:'
      @twitter.attributes.slice('personality', 'values', 'needs').each do |k,v|
        puts "  #{k.humanize}: #{v}"
      end
      
      current_customer.start_conversation
    else
      redirect_to login_path, flash: { danger: 'You must log in as customer to view your profile' }
    end
  end
  
  def clear_messages
    @customer = Customer.find params[:id]
    @customer.messages.destroy_all
    @customer.context = nil
    unless @customer.save
      flash.now[:danger] = "There was an error when deleting the messages for customer #{params[:id]}"
    end
    redirect_to admin_path
  end

  private

  def message_params
    params.require(:customer)
  end
end
