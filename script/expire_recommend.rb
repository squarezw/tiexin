HotSpot.connection.update("update hot_spots set recommend = false where recommend = true and recommend_expire_at < now()")