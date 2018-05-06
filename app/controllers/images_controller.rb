class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: [:show]

  def index
    @q = @account.images.ransack(params[:q])
    if params[:q].present?
      @images = @q.result(distinct: true).where.not(thumbnail_width: nil, thumbnail_height: nil, image_width: nil, image_height: nil).order("created_at desc").page params[:page]
    else
      @images = @account.images.where.not(thumbnail_width: nil, thumbnail_height: nil, image_width: nil, image_height: nil).order("created_at desc").page params[:page]
    end
    @new_image = Image.new
    
  end

  def create
    options = image_params
    options[:created_by] = current_user.id
    @image = Image.new(options)

    respond_to do |format|
      if @image.save
        track_activity(@image)
        format.json { render json: {success: true, data: @image}, status: 200 }
        format.html { redirect_to account_images_path(@account), notice: 'Image will be added shortly.' }
      else
        format.json { render json: {success: false, errors: @image.errors.full_messages }, status: 400 }
        format.html { redirect_to account_images_path(@account), alert: @image.errors.full_messages }
      end
    end
  end

  def show
    @new_image = Image.new
    @image_variation = ImageVariation.new
    @activities = @image.activities.order("updated_at DESC").limit(30)
    
  end

  private

  def set_image
    @image = @account.images.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:account_id, :image, :name, :description, :crop_x, :crop_y, :crop_w, :crop_h, :dominant_colour, :colour_palette, :image_w, :image_h, :credits, :credit_link, :instant_output)
  end
end
