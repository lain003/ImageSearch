import React from "react"
import PropTypes from "prop-types"
import MetaFrame from "./MetaFrame";
import loadsh from 'lodash';
import Popup from "./Popup";

class MetaFrames extends React.Component {
  constructor(props) {
    super(props);
    this.show_popup = this.show_popup.bind(this);
    this.state = {
      is_show: false,
      meta_frame: null
    };
  }

  show_popup(meta_frame) {
    this.setState({
      is_show: true,
      meta_frame: meta_frame
    });
  }

  hide_popup() {
    this.setState({
      is_show: false,
      meta_frame: null
    });
  }

  render () {
    const meta_chunked = loadsh.chunk(this.props.meta_frames, 2);
    return (
      <React.Fragment>
        {meta_chunked.map((meta_frames, i) => (
          <div key={i} className="row">
            {meta_frames.map((meta_frame) => (
              <MetaFrame meta_frame={meta_frame}
                         key={meta_frame.id}
                         click_function={() => this.show_popup(meta_frame)}
                         twitter_image_path={this.props.twitter_image_path} />
            ))}
          </div>
        ))}
        <Popup meta_frame={this.state.meta_frame} is_show={this.state.is_show}
               click_function={() => this.hide_popup()} />
      </React.Fragment>
    );
  }
}

MetaFrames.propTypes = {
  meta_frames: PropTypes.array,
  twitter_image_path: PropTypes.string
};
export default MetaFrames
