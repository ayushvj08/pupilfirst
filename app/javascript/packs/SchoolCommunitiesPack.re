[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  communities: list(SchoolCommunities__Community.t),
  courses: list(SchoolCommunities__Course.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    communities:
      json |> field("communities", list(SchoolCommunities__Community.decode)),
    courses:
      json |> field("courses", list(SchoolCommunities__Course.decode)),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="school-communities",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolCommunities__Index
    authenticityToken={props.authenticityToken}
    communities={props.communities}
    courses={props.courses}
  />,
  "school-communities",
);