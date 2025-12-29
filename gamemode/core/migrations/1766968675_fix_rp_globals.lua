return function(db)
	db:Query([[ALTER TABLE `rp_globals` DROP COLUMN IF EXISTS `Created_At`]])
	db:Query([[ALTER TABLE `rp_globals` DROP COLUMN IF EXISTS `Deleted_At`]])
end
