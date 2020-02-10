import React from "react"
import PropTypes from "prop-types"
import Popup from "reactjs-popup";

class MetaFrame extends React.Component {
  render () {
    const head_path = location.protocol + "//" + location.hostname;
    const twitter_path = "https://twitter.com/share?text=&url="
      + head_path + Routes.meta_frame_path(this.props.meta_frame.id);
    const image_path = "https://twitter.com/share?text=&url="
      + head_path + Routes.meta_frame_gif_path(this.props.meta_frame.id);
    return (
      <React.Fragment>
        <div className="col-lg-6 meta-frame" test_data={this.props.meta_frame.id}>
          <div className="box">
            <div onClick={ () => this.props.popupSnow(this.props.meta_frame) }>
              <img className="img-fluid anime" alt="" src={this.props.meta_frame.image_url} />
            </div>
            <Popup trigger={<img src={this.props.imagePaths["twitter"]} className="twitter-icon" />} position="top center">
              <ul className={"type_choice"}>
                <li>
                  <a href={twitter_path}>Imageを共有</a>
                </li>
                <li>
                  <a href={image_path}>Gifを共有</a>
                </li>
              </ul>
            </Popup>
            <a href={this.props.meta_frame.gif_path}>
              <button type="button" className="btn btn-primary">
                Gifの範囲指定
              </button>
            </a>
          </div>
        </div>
      </React.Fragment>
    );
  }
}



MetaFrame.propTypes = {
  meta_frame: PropTypes.object
};

export default MetaFrame
