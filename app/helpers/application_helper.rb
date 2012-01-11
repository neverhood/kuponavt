module ApplicationHelper

  def ajax_pagination_url(url, page)
    if params[:categories]
      categories = params[:categories].gsub(',','|')
      url = "#{url.gsub(/\?.*/, '')}##{page},#{categories}"
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
