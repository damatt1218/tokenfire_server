class ChargesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def index
  end

  def add
    @cumulative_budget = current_user.account.getCumulativeCampaignBudget
    @max_budget_to_add = @cumulative_budget - current_user.account.developer_balance
    if @max_budget_to_add < 0
      @max_budget_to_add = 10
    end
  end

  def create

    if !params.has_key?(:add_balance)
      flash[:error] = "Credit Card not charged: Amount of money to add is invalid."
      redirect_to charges_add_balance_path
    elsif params[:add_balance].blank?
      flash[:error] = "Credit Card not charged: Amount of money to add cannot be blank."
      redirect_to charges_add_balance_path
    else
      @add_balance = params[:add_balance]
      regex = /^\d+??(?:\.\d{0,2})?$/
      if !regex.match(@add_balance)
        flash[:error] = "Credit Card not charged: Invalid dollar amount."
        redirect_to charges_add_balance_path
      else
        @cumulative_budget = current_user.account.getCumulativeCampaignBudget
        @max_budget_to_add = @cumulative_budget - current_user.account.developer_balance
        if @max_budget_to_add < 0
          @max_budget_to_add = 0
        end
        if @add_balance.to_f > 50
          flash[:error] = "Credit Card not charged: Amount of money to add is too large. Must be less than: " + number_to_currency(@max_budget_to_add, :unit => "$")
          redirect_to charges_add_balance_path
        else
          # Amount in cents
          @amount = (params[:add_balance].to_f * 100).to_i

          customer = Stripe::Customer.create(
              :email => current_user.username,
              :card  => params[:stripeToken]
          )

          charge = Stripe::Charge.create(
              :customer    => customer.id,
              :amount      => @amount,
              :description => 'Add balance to TokenFire',
              :currency    => 'usd'
          )

          current_user.account.developer_balance += @amount / 100.0
          current_user.account.save
        end
      end
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_add_balance_path
  end

end
