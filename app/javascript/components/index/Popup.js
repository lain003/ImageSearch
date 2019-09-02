import React from "react"
import PropTypes from "prop-types"

class Popup extends React.Component {
  render() {
    return (
      <div onClick={this.props.click_function}>
        { this.props.is_show ?
          <div className='popup'>
            <div className='popup_inner'>
              <img src={this.props.meta_frame.gif_url} />
            </div>
          </div>
          :null }
      </div>

    );
  }
}

Popup.propTypes = {
  meta_frame: PropTypes.object,
  is_show: PropTypes.bool
};
export default Popup