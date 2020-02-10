export const SHOW = "SHOW"
export const HIDE = "HIDE"

export const show = (metaFrame) => {
  return {
    type: SHOW,
    payload: { metaFrame: metaFrame }
  };
}

export const hide = () => {
  return {
    type: HIDE
  };
}