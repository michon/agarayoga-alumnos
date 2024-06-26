// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

//= require chartkick
//= require Chart.bundle
//
//= require clipboard
//= require jquery
//= require jquery_ujs

import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "bootstrap"
import "chartkick/chart.js"

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("bootstrap")
require("chartkick")
require("chart.js")
// stylesheets
require("../stylesheets/main.scss")

Rails.start()
Turbolinks.start()
ActiveStorage.start()

global.toastr = require("toastr")
