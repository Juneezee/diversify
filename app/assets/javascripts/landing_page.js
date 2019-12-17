//= require application

//Response on newsletter subscription success/fail
$('#newsletterSubForm').on('ajax:success', (event, data) => {
  if (data.hasOwnProperty('class')) {
    showNotification(data.class, data.message);
  } else {
    const container = $('#formContainer');
    container.html(data.html);
  }
});

//Show notification on landing page feedback submission success/fail
$('#feedbackForm').on('ajax:success', function (event, data) {
  if (data.hasOwnProperty('class')) {
    showNotification(data.class, data.message);
    this.innerHTML = `
      <p class="subtitle is-5 has-text-centered">Thank you for your feedback</p>
    `;
  }
}).on('ajax:error', function (event, data) {
  if (data.responseJSON.hasOwnProperty('class')) {
    showNotification(data.responseJSON.class, data.responseJSON.message);
  }
});

//Event listeners for iframe social share button
$(document).ready(function() {
  //Sends a function whenever a iframe is focused
  window.addEventListener('blur',function(){
    if(document.activeElement instanceof HTMLIFrameElement){
        $.ajax({
        url: '/track_social',
        type: 'post',
        contentType: 'application/json',
        data: JSON.stringify({
          value: document.activeElement.dataset.value
        }),
      });
    }
  });
  
  //Resets focus when user moves from button
  $(window).on('touchend mouseover',function(){
    window.focus()
  })
});

/**
 * Ajax call to send time spent when user enters another page
 */
const startTime = performance.now();

// Track time
window.addEventListener('unload', () => {
  const endTime = performance.now();
  $.ajax({
    url: '/track_time',
    type: 'post',
    async: false,
    contentType: 'application/json',
    data: JSON.stringify({
      time: endTime - startTime,
      pathname: window.location.pathname,
    }),
  });
}, false);
