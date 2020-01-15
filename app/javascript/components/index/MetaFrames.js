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
      meta_frame: null,
      meta_frames: props.meta_frames,
      page: 1,
      is_end: false,
      is_loading: false
    };
  }

  componentDidMount() {
    window.addEventListener('scroll', event => this.watchCurrentPosition(), true)
  }

  watchCurrentPosition() {
    //ページ全体の高さ - ウィンドウの高さ = ページの最下部位置
    let bottom = $(document).innerHeight() - $(window).innerHeight();
    if (bottom <= $(window).scrollTop()) {
      this.add_metaframes();
    }
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
    const meta_chunked = loadsh.chunk(this.state.meta_frames, 2);
    return (
      <React.Fragment>
        {meta_chunked.map((meta_frames, i) => (
          <div key={i} className="row">
            {meta_frames.map((meta_frame) => (
              <MetaFrame meta_frame={meta_frame}
                         key={meta_frame.id}
                         click_function={() => this.show_popup(meta_frame)}
                         twitter_image_path={this.props.image_paths["twitter"]} />
            ))}
          </div>
        ))}
        { this.state.is_loading ?
          <img className="loading" src={this.props.image_paths["loading"]} />
          :null }
        <Popup meta_frame={this.state.meta_frame} is_show={this.state.is_show}
               click_function={() => this.hide_popup()} />
      </React.Fragment>
    );
  }

  get_query () {
    let vars = {};
    let hash  = window.location.search.slice(1).split('&');
    for (let i = 0; i < hash.length; i++) {
      let array = hash[i].split('=');
      vars[array[0]] = array[1];
    }

    return vars;
  }

  add_metaframes () {
    if (this.state.is_end) {
      return;
    }

    let querys = this.get_query();
    let url = "/meta_frames/index.json?" + "page=" + (this.state.page + 1);
    if (querys["words"] != null) {
      url += "&words=" + querys["words"]
    }
    this.setState({ is_loading: true });
    fetch(url)
    .then(res => res.json())
    .then(
      (result) => {
        if (result.length == 0) {
          this.setState({ is_end: true });
        } else {
          this.setState({
            meta_frames: this.state.meta_frames.concat(result),
            page: this.state.page + 1
          });
        }
      },
      (error) => {
        console.error(error);
      }
    )
    .then( _ => this.setState({ is_loading: false }))
  }
}

MetaFrames.propTypes = {
  meta_frames: PropTypes.array,
  image_paths: PropTypes.object
};
export default MetaFrames
