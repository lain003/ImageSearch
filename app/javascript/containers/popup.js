import { connect } from 'react-redux';
import * as actions from '../actions/popup';
import MetaFrames from '../components/index/Popup';

const mapStateToProps = state => {
  return {
    isShow: state.popup.isShow,
    metaFrame: state.popup.metaFrame
  }
}

const mapDispatchToProps = dispatch => {
  return {
    hide: () => dispatch(actions.hide())
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(MetaFrames)