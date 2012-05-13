# -*- encoding : utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Notification.delete_all
Rating.delete_all
Notification.delete_all
OfferMessage.delete_all
Payment.delete_all
Offer.delete_all
Item.update_all("item_status = 'Available'")

