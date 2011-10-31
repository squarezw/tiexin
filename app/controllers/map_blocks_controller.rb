require 'str_helper'

class MapBlocksController < ApplicationController
  before_filter :find_current_user, :find_current_city, :except=>:show
  
  helper 'hot_spots'
  
  def show
    adjust_current_city City.find(params[:city_id])
    x=params[:x].to_s.right_padding('0', 8)
    y=params[:y].to_s.right_padding('0', 8)
    xi = params[:x].to_i
    yi = params[:y].to_i
    rel_path = "#{params[:city_id]}/#{params[:level]}/#{yi/10}/#{xi/10}/#{y}_#{x}.png"
    full_path="#{XNavi::MAP_BLOCK_DIR}/#{rel_path}"
    logger.info "map_block path: #{full_path}"
    respond_to do |format|
      format.image { 
        if @mobile_user or XNavi::MAP_BLOCKS_SEND_MODE =~ /send_file/i
            if File.exists?(full_path)
              response.headers['Cache-Control']='max-age=86400'
              send_file full_path, :type=>'image/png', :disposition=>'inline'
            else
              render :nothing=>true, :status=>404
            end  
        else
            redirect_to "/images/map_blocks/#{rel_path}"
        end
        }
      format.xml { 
          @category_id = params[:category_id]
          parse_start_limit
          if File.exists?(full_path) 
            @map_block = @current_city.map_levels.find_by_no(params[:level]).map_block_at(params[:x].to_i, params[:y].to_i)
            render :template => 'map_blocks/show.rxml' 
          else
            error_xml(201) 
          end  
      }
    end
  end
  
  def parse_start_limit
    @start = params[:start].to_i if params[:start]
    @limit = params[:limit].to_i if params[:limit]
  end
end
