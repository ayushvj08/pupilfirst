[@bs.config {jsx: 3}];

[@react.component]
let make = (~closeDrawerCB, ~closeButtonTitle="Close Editor", ~children) =>
  <div>
    <div className="blanket" />
    <div className="drawer-right">
      <div className="drawer-right__close absolute">
        <button
          onClick={
            e => {
              e |> ReactEvent.Mouse.preventDefault;
              closeDrawerCB();
            }
          }
          title=closeButtonTitle
          className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
          <i className="fal fa-times text-2xl" />
        </button>
      </div>
      <div className="w-full overflow-y-scroll"> children </div>
    </div>
  </div>;

module Jsx2 = {
  let component =
    ReasonReact.statelessComponent("SchoolCustomize__EditorDrawer");

  let make = (~closeDrawerCB, ~closeButtonTitle="Close Editor", children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(
        ~closeDrawerCB,
        ~closeButtonTitle,
        ~children=children |> React.array,
        (),
      ),
      children,
    );
};