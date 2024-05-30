/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "bootstrap"
//= app/javascript/packs/application.js
//= require("chartkick")
//= require("chart.js")

//= require Chart.bundle
//= require chartkick

//= require clipboard

import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "chartkick/chart.js"
import "bootstrap"
import 'bootstrap/dist/js/bootstrap'
import 'bootstrap/dist/css/bootstrap'

require("stylesheets/application.scss")

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("bootstrap")
require("chartkick")
require("chart.js")
// stylesheets
//require("../stylesheets/main.scss")

Rails.start()
Turbolinks.start()
ActiveStorage.start()

global.toastr = require("toastr")
var jQuery = require('jquery')
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;
import * as echarts from "echarts";
import "echarts/theme/dark";

window.echarts = echarts;


