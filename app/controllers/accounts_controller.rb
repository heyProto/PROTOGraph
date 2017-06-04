class AccountsController < ApplicationController

  before_action :authenticate_user!

  def show
    redirect_to account_permissions_path(@account)
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      @account.create_permission(current_user.id)
      redirect_to @account, notice: t("cs")
    else
      render :new
    end
  end

  private

    def account_params
      params.require(:account).permit(:username, :slug, :domain)
    end

end
