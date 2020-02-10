import React from "react"
import PropTypes from "prop-types"
import MetaFrame from "../../containers/metaFrame";
import loadsh from 'lodash';
import Popup from '../../containers/popup';

class MetaFrames extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      meta_frame: null,
      page: 1,
      is_end: false,
      is_loading: false
    };

    props.initializeMetaFrames(props.meta_frames);
    props.initializeImagePaths(props.image_paths);
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

  render () {
    const meta_chunked = loadsh.chunk(this.props.metaFrames, 2);
    return (
        <React.Fragment>
          {meta_chunked.map((meta_frames, i) => (
            <div key={i} className="row">
              {meta_frames.map((meta_frame) => (
                <MetaFrame meta_frame={meta_frame}
                           key={meta_frame.id} />
              ))}
            </div>
          ))}
          { this.state.is_loading ?
            <img className="loading" src={this.props.imagePaths["loading"]} />
            :null }
          <Popup />
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
    if (this.state.is_end || this.state.is_loading) {
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
          this.props.addMetaFrames(result);
          this.setState({
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
