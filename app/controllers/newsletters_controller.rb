class NewslettersController < ApplicationController

    layout 'metrics_page'

    def index
        @newsletters = Newsletter.all 
    end

    def new
        @newsletter = Newsletter.new
    end

    def create
        @newsletter = Newsletter.new(newsletter_params)

        if @newsletter.save
            print (@newsletter)
        end
    end

    def show
        @newsletter = Newsletter.where('id = ?', params[:id]).first

        respond_to do |format|
            format.json { render :json => {title: @newsletter.title, content:@newsletter.content}, :status => 200 }
        end
    end

      
    def newsletter_params
        params.require(:newsletter).permit(:title, :content)
    end
  
end
