//= require jquery
//= require jquery_ujs

'use strict';

// Check for click events on the navbar burger icon
$('.navbar-burger').click(function() {

  // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
  $('.navbar-burger').toggleClass('is-active');
  $('.navbar-menu').toggleClass('is-active');

});

const openTab = (evt, tabName) => {
  $('.content-tab').each(function() {
    $(this).removeClass('show');
  });
  $('.tab').each(function() {
    $(this).removeClass('is-active');
  });
  $('#' + tabName).addClass('show');
  evt.currentTarget.className += ' is-active';
};
