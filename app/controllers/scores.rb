module XNavi
  module Score
    SCORE_RULES={
      :hot_spot_approved => {:credit=> 10},
      :post_comment => {:experience=> 5},
      :comment_agree => {:credit=> 5},
      :comment_disagree => { :credit=> -5 },
      :submit_revise_advice => {:experience => 5},
      :revise_advice_accepted => {:credit=> 3},
      :recommend_product => {:experience => 10},
      :upload_photo => {:experience => 10},
      :invite_member => {:experience => 50},
      :new_post => {:experience => 10},
      :new_reply => {:experience => 1},
      :good_post => {:credit=> 5},
      :hidden_post => {:credit=> -3},
      :water_post => {:credit => -1},
      :good_reply => {:credit => 3},
      :hidden_reply => {:credit=> -1},
      :delete_post => {:credit=> 0},
      :delete_reply => {:credit=> 0}
    }
    
    def score(event, member=nil, score=0)
      raise ArgumentError, "Unkown event: #{event}" unless SCORE_RULES.has_key?(event)
      member = @current_user if member.nil?
      SCORE_RULES[event].each_pair { |key, value| 
        score = value if score == 0
        member.score! key, score
      }
    end
  end
end