class StoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page, only: [:edit_plan, :edit_write, :edit_assemble, :edit_distribute]
  before_action :sudo_can_see_all_pages, only: [:edit_plan, :edit_write, :edit_assemble, :edit_distribute]

  def index
    if params[:page].present? and params[:page].class != String
      p_params = page_params
      if p_params.has_key?('cover_image_attributes') and !p_params['cover_image_attributes'].has_key?("image")
        p_params.delete('cover_image_attributes')
      end
      @page = Page.new(p_params)
      @page.headline = @page.one_line_concept
      @page.english_headline = @page.one_line_concept unless @site.is_english
      @page.created_by = current_user.id
      @page.updated_by = current_user.id
      @page.collaborator_lists = ["#{current_user.id}"] if ["contributor", "writer"].include?(@permission_role.slug)
      if @page.save
        redirect_to account_site_stories_path(@account, @site, folder_id: @page.folder_id), notice: 'Page was successfully created.'
      else
        render :back, alert: @page.errors.full_messages
      end
    else
      if @permission_role.can_see_all_pages
        @pages = @folder.pages.where(template_page_id: TemplatePage.where(name: "article").pluck(:id).uniq).order(updated_at: :desc).page(params[:page]).per(30)
      else
        @pages = current_user.pages(@folder).where(template_page_id: TemplatePage.where(name: "article").pluck(:id).uniq).order(updated_at: :desc).page(params[:page]).per(30)
      end
      @page = Page.new
      @ref_intersection = RefCategory.where(site_id: @site.id, genre: "intersection", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
      @ref_sub_intersection = RefCategory.where(site_id: @site.id, genre: "sub intersection", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
      @article = TemplatePage.where(name: "article").first
    end
  end

  def edit_plan
    @ref_intersection = RefCategory.where(site_id: @site.id, genre: "intersection", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
    @ref_sub_intersection = RefCategory.where(site_id: @site.id, genre: "sub intersection", is_disabled: [false, nil]).order(:name).map {|r| ["#{r.name}", r.id]}
    @template_cards = @account.template_cards.where(is_current_version: true)
    @page_todo = PageTodo.new
    @page_todos = @page.page_todos.order(:sort_order)
    #  ->>> page_authors
  end

  def edit_assemble
    @view_cast = @page.view_cast if @page.view_cast_id.present?
    @page_streams = @page.page_streams
    @page.publish = @page.status == 'published'
    @is_article_page = @page.template_page.name == "article"
    @image = @page.cover_image
    if @image.blank?
        @page.build_cover_image
    end
    #  cover_image_id_7_column          :integer
    #  cover_image_id_4_column
    #  cover_image_id_3_column
    #  cover_image_id_2_column
    #  cover_image_credit
    if @page.status != "draft"
        @page_stream_narrative = @page.streams.where(title: "#{@page.id.to_s}_Story_Narrative").first
        @page_stream_related = @page.streams.where(title: "#{@page.id.to_s}_Story_Related").first
        @page_stream_related7c = @page_stream_related.page_streams.first
        @page_stream_narrative7c = @page_stream_narrative.page_streams.first
        exclude_view_casts = StreamEntity.view_casts.where(stream_id: [@page_stream_narrative.id, @page_stream_related.id]).pluck(:entity_value)
        @all_cards = @site.view_casts.where.not(id: exclude_view_casts).where(is_autogenerated: false).where(folder_id: @site.folders.active.where(ref_category_vertical_id: @page.series.id, is_for_stories: true).pluck(:id)).order([updated_at: :desc, created_at: :desc])
        if @page.template_page.name == "Homepage: Vertical"
          title = "#{@page.id.to_s}_Section_16c_Hero"
        elsif @page.template_page.name == "article"
          title = "#{@page.id.to_s}_Story_16c_Hero"
        else
          title = "#{@page.id.to_s}_Data_16c_Hero"
        end
        @page_stream_16 = @page.streams.where(title: title).first
        @page_streamH16 = @page.page_streams.where(name_of_stream: "Hero").first
        @stream_entity = StreamEntity.new
    end
  end

  def edit_write
    #- Seamless writing experience that gets converted into many Compose Cards
    #- Rao's app / Medium / Google Doc
  end

  def edit_distribute
    #  cover_image_url_facebook         :text(65535)
    #  cover_image_url_square           :text(65535)
    # - Tags []
    # - Related to Geography?
    #     > Country
    #     > State
    #     > District
    #     > Location
  end

  private

    def set_page
      @page = Page.friendly.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:id, :account_id, :site_id, :folder_id, :headline, :meta_keywords, :meta_description, :summary, :template_page_id, :byline, :one_line_concept,
                                   :cover_image_url, :cover_image_url_7_column, :cover_image_url_facebook, :cover_image_url_square, :cover_image_alignment, :content,
                                   :is_sponsored, :is_interactive, :has_data, :has_image_other_than_cover, :has_audio, :has_video, :status, :published_at, :url,
                                   :ref_category_series_id, :ref_category_intersection_id, :ref_category_sub_intersection_id, :view_cast_id, :page_object_url, :created_by,
                                   :updated_by, :english_headline, :due, :description, :cover_image_id_4_column, :cover_image_id_3_column, :cover_image_id_2_column, :cover_image_credit, :share_text_facebook,
                                     :share_text_twitter, :publish, :prepare_cards_for_assembling,collaborator_lists: [], cover_image_attributes: [:image, :account_id, :is_cover, :created_by,
                                     :updated_by])
    end
end
