class Customer < ApplicationRecord
  belongs_to :user
  
  # TODO: point from customer to twitter_personality
  has_one :twitter_personality
  has_many :transactions
  has_many :messages
  
  serialize :context, JSON
  
  
  def get_personality
    puts ' '
    puts "Fetching Personality Insights from #{self.name}'s tweets..."
    WatsonPersonalityInsights.new
  end
  
  def extract_signals(tweets)
    puts ' '
    puts "Fetching Signals from #{self.name}'s tweets..."
    NaturalLanguageUnderstanding.extract_keywords(tweets)
  end
  
  def update_churn
    churn = MlScoring.new self
    if churn.result
      self.update! churn.result
    end
  end
  
  def will_churn?
    update_churn
    self.churn_prediction
  end
  
  def name
    self.user.name
  end
  
  def twitter_id
    self.twitter_personality.username
  end
  
  def gender
    self.sex == 'M' ? 'Male' : 'Female'
  end
  
  def reset
    clear_conversation
    clear_prediction
  end
  
  private
  
  def start_conversation
    Message.send_to_watson_conversation('', self) if messages.empty?  # Send empty string to Watson Conversation
  end
  
  def clear_conversation
    messages.destroy_all
    self.context = nil
    self.save
  end
  
  def clear_prediction
    self.churn_prediction = nil
    self.churn_probability = nil
    self.save!
  end
  
end
