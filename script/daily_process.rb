Member.connection.delete("delete from members where created_at < date_sub(current_date(),interval 2 day) and confirmed = 0")

HotSpot.connection.update("update hot_spots set visit_count = 0")

HotSpot.connection.update("update hot_spots a ,(select hot_spot_id, count(hot_spot_id) as vc from hot_spot_access_logs where created_at > date_sub(current_date(),interval 30 day) group by hot_spot_id) b set visit_count = b.vc where a.id = b.hot_spot_id")

HotSpot.connection.update("update hot_spots set recommend = false where recommend = true and recommend_expire_at < now()")

HotSpot.connection.update('delete from sessions where now() - updated_at > 14400')

