class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page, only: [:edit, :update, :destroy, :remove_cover_image, :distribute]
  before_action :sudo_can_see_all_pages, only: [:edit, :update, :manager, :remove_cover_image, :create, :distribute]

  def manager
    @genre = "series"
    @data = @site.verticals.order(:name)
    @instance = @site.verticals.new
    @is_page_builder = true
  end

  def distribute
    @is_page_builder = true
    @cover_image_alignment = ['vertical', 'horizontal'].map {|r| ["#{r.titlecase}", r]}
    @page.publish = @page.status == 'published'
    @image = @page.cover_image
    if @image.blank?
      @page.build_cover_image
    end
  end

  def edit
    if @page.template_page.name == "article"
      redirect_to edit_write_account_site_story_path(@account, @site, @page, folder_id: @page.folder_id)
    else
      @is_page_builder = true
      @page.publish = @page.status == 'published'
      @image = @page.cover_image
      if @image.blank?
        @page.build_cover_image
      end
      if @page.template_page.name == "Homepage: Vertical"
        @page_stream_16 = @page.streams.where(title: "#{@page.id.to_s}_Section_16c_Hero").first
        @page_stream_07 = @page.streams.where(title: "#{@page.id.to_s}_Section_7c").first
        @page_stream_04 = @page.streams.where(title: "#{@page.id.to_s}_Section_4c").first
        @page_stream_03 = @page.streams.where(title: "#{@page.id.to_s}_Section_3c").first
        @page_stream_02 = @page.streams.where(title: "#{@page.id.to_s}_Section_2c").first
        @page_streamH16 = @page_stream_16.page_streams.where(page_id: @page.id).first
        @page_streamH07 = @page_stream_07.page_streams.where(page_id: @page.id).first
        @page_streamH04 = @page_stream_04.page_streams.where(page_id: @page.id).first
        @page_streamH03 = @page_stream_03.page_streams.where(page_id: @page.id).first
        @page_streamH02 = @page_stream_02.page_streams.where(page_id: @page.id).first
        exclude_view_casts = StreamEntity.view_casts.where(stream_id: [@page_stream_16.id, @page_stream_07.id, @page_stream_04.id, @page_stream_03.id, @page_stream_02.id]).pluck(:entity_value)
        @all_cards = @site.view_casts.where.not(id: exclude_view_casts).where(folder_id: @site.folders.active.where(ref_category_vertical_id: @page.series.id, is_for_stories: true).pluck(:id)).order([updated_at: :desc, created_at: :desc])
        @stream_entity = StreamEntity.new
      end
      render layout: "application-pages"
    end
  end

  def update
    @page.updated_by = current_user.id
    p_params = page_params
    if params[:commit] == 'Publish'
      p_params["status"] = 'publish'
    end
    if p_params.has_key?('cover_image_attributes') and !p_params['cover_image_attributes'].has_key?("image")
      p_params.delete('cover_image_attributes')
    end
    from_page = params[:page][:from_page]


    respond_to do |format|
      if @page.update_attributes(p_params)
        format.json { respond_with_bip(@page) }
        format.html {
          if @page.template_page.name == "article" and from_page == "edit_write"
            redirect_to edit_assemble_account_site_story_path(@account, @site, @page, folder_id: @page.folder_id)
          else
            redirect_back(fallback_location: account_site_pages_path(@account, @site, folder_id: (@folder.present? ? @folder.id : nil)), notice: 'Page was successfully updated.')
          end
        }
      else
        format.json { respond_with_bip(@page) }
        format.html {
          @ref_series = RefCategory.where(site_id: @site.id, genre: "series", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
          @ref_intersection = RefCategory.where(site_id: @site.id, genre: "intersection", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
          @ref_sub_intersection = RefCategory.where(site_id: @site.id, genre: "sub intersection", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
          @cover_image_alignment = ['vertical', 'horizontal'].map {|r| ["#{r.titlecase}", r]}
          @view_cast = @page.view_cast if @page.view_cast_id.present?
          @page_streams = @page.page_streams
          @page.publish = @page.status == 'published'
          if @page.status != "draft"
            if @page.template_page.name == "Homepage: Vertical"
              @is_page_builder = true
              @page_stream_16 = @page.streams.where(title: "#{@page.id.to_s}_Section_16c_Hero").first
              @page_stream_16.view_cast_id_list = @page_stream_16.view_cast_ids.pluck(:entity_value).join(",")
              @page_stream_07 = @page.streams.where(title: "#{@page.id.to_s}_Section_7c").first
              @page_stream_07.view_cast_id_list = @page_stream_07.view_cast_ids.pluck(:entity_value).join(",")
              @page_stream_04 = @page.streams.where(title: "#{@page.id.to_s}_Section_4c").first
              @page_stream_04.view_cast_id_list = @page_stream_04.view_cast_ids.pluck(:entity_value).join(",")
              @page_stream_03 = @page.streams.where(title: "#{@page.id.to_s}_Section_3c").first
              @page_stream_03.view_cast_id_list = @page_stream_03.view_cast_ids.pluck(:entity_value).join(",")
              @page_stream_02 = @page.streams.where(title: "#{@page.id.to_s}_Section_2c").first
              @page_stream_02.view_cast_id_list = @page_stream_02.view_cast_ids.pluck(:entity_value).join(",")
              @page_streamH16 = @page_stream_16.page_streams.where(page_id: @page.id).first
              @page_streamH07 = @page_stream_07.page_streams.where(page_id: @page.id).first
              @page_streamH04 = @page_stream_04.page_streams.where(page_id: @page.id).first
              @page_streamH03 = @page_stream_03.page_streams.where(page_id: @page.id).first
              @page_streamH02 = @page_stream_02.page_streams.where(page_id: @page.id).first
              @all_cards = @site.view_casts.where.not(id: exclude_view_casts).where(is_autogenerated: false).where(folder_id: @site.folders.active.where(ref_category_vertical_id: @page.series.id, is_for_stories: true).pluck(:id)).order([:updated_at, :created_at])
              @stream_entity = StreamEntity.new

            end
          end
          render :action => "edit", alert: @page.errors.full_messages
        }
      end
    end
  end

  def remove_cover_image
    @page.update_attributes(cover_image_id: nil, cover_image_id_7_column: nil)
    redirect_back(fallback_location: account_site_pages_path(@account, @site, folder_id: (@folder.present? ? @folder.id : nil)), notice: t("ds"))
  end

  def destroy
    f = @page.folder_id
    @page.destroy
    redirect_to account_site_pages_path(@account, @site, folder_id: f), notice: 'Page was successfully destroyed.'
  end

  private

    def set_page
      @page = Page.friendly.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:id, :account_id, :site_id, :folder_id, :headline, :meta_keywords, :meta_description, :summary, :template_page_id, :byline_id, :one_line_concept,
                                   :cover_image_url, :cover_image_url_7_column, :cover_image_url_facebook, :cover_image_url_square, :cover_image_alignment, :content,
                                   :is_sponsored, :is_interactive, :has_data, :has_image_other_than_cover, :has_audio, :has_video, :status, :published_at, :url,
                                   :ref_category_series_id, :ref_category_intersection_id, :ref_category_sub_intersection_id, :view_cast_id, :page_object_url, :created_by,
                                   :updated_by, :english_headline, :due, :description, :cover_image_id_4_column, :cover_image_id_3_column, :cover_image_id_2_column, :cover_image_credit, :share_text_facebook,
                                     :share_text_twitter, :publish, :prepare_cards_for_assembling,collaborator_lists: [], cover_image_attributes: [:image, :account_id, :is_cover, :created_by,
                                     :updated_by])
    end
end
