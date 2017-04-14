import { withPluginApi } from 'discourse/lib/plugin-api';
import SharePopupComponent from 'discourse/components/share-popup';
import { ajax } from 'discourse/lib/ajax';

function initializeSegment(api) {
  SharePopupComponent.reopen({
    didInsertElement() {
      this._super();
      const $html = $('html');
      $html.on('click.discoure-share-link', '[data-share-url]', e => {
        var post_id = this.postId;
        if (Discourse.User.current()){
          var user_id = Discourse.User.current().id;
        }
        else{
          var user_id = 0;
        }
        ajax("/segment-io/track-share", {
          data: JSON.stringify({"user_id" : user_id , "post_id" : post_id }),
          type: "POST",
          datatype: "json",
          contentType: 'application/json' 
        });
      });
    }
  });
}

export default {
  name: "apply-segment",

  initialize() {
    withPluginApi('0.5', initializeSegment);
  }
};