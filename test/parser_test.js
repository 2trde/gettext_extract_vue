const Component = () => {
  return (
    <div>
      {/* @translations free_delivery|costly_delivery */}
      {(gettext("Hello World"), yolo("what"))}
      <Translate>Hello World</Translate>
    </div>
  );
};

export class ClassComponent {
  constructor() {}

  render() {
    return (
      <div>
        Hello
        {this.props.t("YOLO")}
      </div>
    );
  }
}

export default Component;
