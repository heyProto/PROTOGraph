class ImagesController < ApplicationController

  def index
    @images = Image.all
    @image = Image.new
  end

  def create
    options = image_params
    options[:tag_list] = options[:tag_list].split(",")
    options[:created_by] = current_user.id
    @image = Image.new(options)
    if @image.save
      redirect_to account_images_path(@account), notice: "Image added successfully"
    else
      redirect_to account_images_path(@account), alert: @image.errors.full_messages
    end
  end

  def show
    @image = Image.where(id: params[:id]).includes(:image_variation).first
    @image_variation = ImageVariation.new
  end

  private

  def set_image
    @image = Image.find(params[:id]) if params[:id]
  end

  def image_params
    params.require(:image).permit(:account_id, :image, :name, :description, :tags, :tag_list)
  end
end