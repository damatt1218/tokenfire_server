module Admin
  class AchievementsController < AdminController

    # GET /achievements
    def index
      @pending_achievements = Achievement.find_all_by_accepted(false)
      @accepted_achievements = Achievement.find_all_by_accepted(true)

      respond_to do |format|
        format.html # index.html.erb
      end
    end

    # GET /achievements/1/edit
    def edit
      @achievement = Achievement.find(params[:id])
    end

    # PUT /achievements/1
    # PUT /achievements/1.json
    def update
      @achievement = Achievement.find(params[:id])

      respond_to do |format|
        if @achievement.update_attributes(params[:achievement])
          format.html { redirect_to admin_achievements_path, :notice => 'Achievement accepted.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  end
end