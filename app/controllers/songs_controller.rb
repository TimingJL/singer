class SongsController < ApplicationController
	before_action :find_song, only: [:show, :edit, :update, :destroy]

    def index
    	@song = Song.all.order("created_at DESC")
    end

    def show
    end

    def new
    	@song = Song.new
    end

    def create
    	@song = Song.new(song_params)
    	if @song.save
    		redirect_to @song, notice: "Successfully created new song"
    	else
    		render 'new'
    	end
    end

    def edit
    end

    def update
        if @song.update(song_params)
            redirect_to @song
        else
            render 'edit'
        end
    end

    def destroy
        @song.destroy
        redirect_to root_path, notice: "Successfully delted song"
    end     

    private

    def song_params
        params.require(:song).permit(:title, :description, links_attributes: [:id, :link, :embed, :_destroy])
    end    

    def find_song
        @song = Song.find(params[:id])
    end

    def find_link
        @link = Link.find(params[:id])
    end
    
    def link_params
        params.require(:link).permit(:link)
    end    
end
