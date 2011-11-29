module ApplicationHelper

  def ajax_pagination_url(url, page)
    if page > 1
      url.gsub!(/\/(\d+)/, "##{page}")
      if params[:categories]
        url.gsub!(/\?categories=.*/, ",#{params[:categories].gsub(',','|')}")
      end

    else
      if params[:categories]
        url.gsub!(/\?categories=.*/, "#1,#{params[:categories].gsub(',','|')}")
      end
    end

    url
  end

  def notification(text)
    %Q(<div class='hidden notification'>
        #{image_tag 'close.png', :class => 'close-popup'}
        #{text}
       </div>).html_safe
  end

end
