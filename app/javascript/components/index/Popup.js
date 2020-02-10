import React from "react"

class Popup extends React.Component {
  render() {
    return (
      <div onClick={ () => this.props.hide() }>
        { this.props.isShow ?
          <div className='popup'>
            <div className='popup_inner'>
              <img src={this.props.metaFrame.gif_url} />
            </div>
          </div>
          :null }
      </div>
    );
  }
}

export default Popup