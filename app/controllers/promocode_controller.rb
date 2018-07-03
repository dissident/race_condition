class PromocodeController < ApplicationController
  before_action :authenticate_user!

  def activate
    @promocode = Promocode.new
  end

  def activation
    # promocode = Promocode.where(
    #   code: promocode_params[:code],
    #   active: true
    # ).lock(true).
    promocode = Promocode
      .active
      .find_by_code(promocode_params[:code])
      .lock(true)
    if promocode.present?
      promocode.activate(current_user)
    else
      flash[:error] = 'Bad promocode'
    end
    redirect_to '/'
  end

  def index
    @promocodes = Promocode.all
  end

  def generate
    Promocode.generate(200)
    redirect_to '/promocodes'
  end

  private

  def promocode_params
    params.require(:promocode).permit(:code)
  end
end
