require 'gettext/rails'

module BbcodeEditor
  include GetText::Rails
  bindtextdomain("bbcode_editor", :path=>File.join(RAILS_ROOT, 'vendor/plugins/bbcode_editor/locale'))
  
  FONT_COLORS=[['black', '#444444', 'Standard'],
               'darkred', 'red', 'orange', 'brown', 'yellow', 'green', 
               'olive', 'cyan', 'blue', 'darkblue', 'indigo', 'violet',
               ['silver', 'white', 'white'],
               'black' ]  
               
   FONT_SIZE=[ [7, 'Smallest'], [9, 'Small'], [12, 'Standard'], [18, 'Large'], [24, 'Largest'] ]  
   
   N_('Smallest')
   N_('Small')
   N_('Standard')
   N_('Large')
   N_('Largest')
	                   
   STYLE_BUTTONS=[ [0, 'B', 'b'],
                   [2, 'i', 'i'],
                   [4, 'u', 'u'],
                   [6, 'Quote', 'q'],
                   [8, 'Code', 'c'],
                   [10, 'Email', 'e'],
                   [12, 'Email=', 'o'],
                   [14, 'Img', 'p'],
                   [16, 'URL', 'w'] ]

  N_('B')
  N_('i')
  N_('u')
  N_('Quote')
  N_('Code')
  N_('Img')
  
   def bbcode_editor(editor_area_id='bbcode_editor') 
<<CONTENT     
 	  <div class="bbeditor_tool_bar">
 		<p>     
 		   #{style_buttons(editor_area_id)}
 		</p>
 		<p><label>#{_('Font Color')}</label>
 		    #{select_font_color(editor_area_id)}
 		   <label>#{_("Font Size")}</label>
 		   #{select_font_size(editor_area_id)}
 		</p>                         
 		<p>
 		  #{smile_buttons(editor_area_id)}
 	  </p>
 	  </div>
CONTENT
   end                                              
   
   private
   def style_buttons(editor_area_id)
     result = STYLE_BUTTONS.inject([]) do |buttons, b|
       buttons << bbeditor_button(editor_area_id, b[0], _(b[1]), b[2])
     end  
     result.join("\n")
   end
   
   def select_font_color (editor_area_id)
     [%Q$<select name="addbbcode18" onchange="bbfontstyle(#{editor_area_id}, '[color='+this.options[this.selectedIndex].value+']', '[/color]');this.selectedIndex=0;" >$,
      font_color_options,  "</select>"].join("\n")
   end                  
   
   def font_color_options
     result = FONT_COLORS.inject([])  do |options, color| 
       if color.is_a?(Array)
         text_color, value, label = color[0], color[1], _(color[2])
       else
         text_color = value = label = color
       end                               
       options << %Q$<option style="color:#{text_color};background-color:white;", value="#{value}">#{label}</options>$
     end                     
     result.join("\n")
   end                                  


   def select_font_size(editor_area_id)
     [%Q$<select name="addbbcode20" onchange="bbfontstyle(#{editor_area_id},  '[size='+this.options[this.selectedIndex].value+']', '[/size]');" >$,
      font_size_options,
      "</select>"].join("\n")
   end                                                              

   def font_size_options
     result = FONT_SIZE.inject([]) do |options, font_size|
       size, label = font_size[0], _(font_size[1])
       options << %Q$<option value="#{size}">#{_(label)}</option>$
     end                                                      
     result.join("\n")
   end                

  
  def smile_buttons(editor_area_id)
    result = (0..39).to_a.inject(Array.new) do |buttons, i|
			 buttons << link_to_function(image_tag("smile/#{i}.gif"), "smile_icon('#{editor_area_id}', #{i})")
       buttons << '<br/>' if (i+1) % 20 == 0
       buttons 
		 end
		 result.join("\n")
  end

    def bbeditor_button(editorAreaId, styleCode, tagName, accesskey)
      %Q$<input type="button" accesskey="#{accesskey}" name="addbbcode#{styleCode}" value=" #{tagName} " onclick="bbstyle('#{editorAreaId}', this, #{styleCode});" class="bbeditor_button" />$
    end                
end