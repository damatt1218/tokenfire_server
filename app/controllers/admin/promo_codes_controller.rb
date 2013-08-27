module Admin
  class PromoCodesController < AdminController
    def index
      @active_promo_codes = PromoCode.find_all_by_active(true)
      @inactive_promo_codes = PromoCode.find_all_by_active(false)
    end

    def show
      @promo_code = PromoCode.find(params[:id])
      @promo_code_history = PromoCodeHistory.find_by_promo_code_id(params[:id])
    end

    def new
      @promo_code = PromoCode.new
    end

    def edit
      @promo_code = PromoCode.find(params[:id])
    end

    def create
      @promo_code = PromoCode.new(params[:promo_code], :as => :admin)

      if @promo_code.save
        redirect_to admin_promo_codes_path, :notice => 'PromoCode was successfully created.'
      else
        render :action => "new", :error => 'Could not create promo_code.'
      end
    end

    def update
      @promo_code = PromoCode.find(params[:id])

      if @promo_code.update_attributes(params[:promo_code], :as => :admin)
        redirect_to admin_promo_codes_path, :notice => 'PromoCode was successfully updated.'
      else
        render :action => "edit", :error => 'Could not update promo_code.'
      end
    end

    def destroy
    end


  end
end
