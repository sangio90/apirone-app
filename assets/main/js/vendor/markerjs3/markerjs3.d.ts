/**
 * Describes a point objects use internally
 */
interface IPoint {
    /**
     * Horizontal (X) coordinate.
     */
    x: number;
    /**
     * Vertical (Y) coordinate.
     */
    y: number;
}

/**
 * Describes a size
 */
interface ISize {
    /**
     * Width
     */
    width: number;
    /**
     * Height
     */
    height: number;
}

/**
 * Represents a simplified version of the SVGMatrix.
 */
interface ITransformMatrix {
    a: number;
    b: number;
    c: number;
    d: number;
    e: number;
    f: number;
}

/**
 * Utility class to simplify SVG operations.
 */
declare class SvgHelper {
    /**
     * Creates SVG "defs".
     */
    static createDefs(): SVGDefsElement;
    /**
     * Sets attributes on an arbitrary SVG element
     * @param el - target SVG element.
     * @param attributes - set of name-value attribute pairs.
     */
    static setAttributes(el: SVGElement, attributes: Array<[string, string]>): void;
    /**
     * Creates an SVG rectangle with the specified width and height.
     * @param width
     * @param height
     * @param attributes - additional attributes.
     */
    static createRect(width: number | string, height: number | string, attributes?: Array<[string, string]>): SVGRectElement;
    /**
     * Creates an SVG line with specified end-point coordinates.
     * @param x1
     * @param y1
     * @param x2
     * @param y2
     * @param attributes - additional attributes.
     */
    static createLine(x1: number | string, y1: number | string, x2: number | string, y2: number | string, attributes?: Array<[string, string]>): SVGLineElement;
    /**
     * Creates an SVG polygon with specified points.
     * @param points - points as string.
     * @param attributes - additional attributes.
     */
    static createPolygon(points: string, attributes?: Array<[string, string]>): SVGPolygonElement;
    /**
     * Creates an SVG circle with the specified radius.
     * @param radius
     * @param attributes - additional attributes.
     */
    static createCircle(radius: number, attributes?: Array<[string, string]>): SVGCircleElement;
    /**
     * Creates an SVG ellipse with the specified horizontal and vertical radii.
     * @param rx
     * @param ry
     * @param attributes - additional attributes.
     */
    static createEllipse(rx: number, ry: number, attributes?: Array<[string, string]>): SVGEllipseElement;
    /**
     * Creates an SVG group.
     * @param attributes - additional attributes.
     */
    static createGroup(attributes?: Array<[string, string]>): SVGGElement;
    /**
     * Creates an SVG transform.
     */
    static createTransform(): SVGTransform;
    /**
     * Creates an SVG marker.
     * @param id
     * @param orient
     * @param markerWidth
     * @param markerHeight
     * @param refX
     * @param refY
     * @param markerElement
     */
    static createMarker(id: string, orient: string, markerWidth: number | string, markerHeight: number | string, refX: number | string, refY: number | string, markerElement: SVGGraphicsElement): SVGMarkerElement;
    /**
     * Creates an SVG text element.
     * @param attributes - additional attributes.
     */
    static createText(attributes?: Array<[string, string]>): SVGTextElement;
    /**
     * Creates an SVG TSpan.
     * @param text - inner text.
     * @param attributes - additional attributes.
     */
    static createTSpan(text: string, attributes?: Array<[string, string]>): SVGTSpanElement;
    /**
     * Creates an SVG image element.
     * @param attributes - additional attributes.
     */
    static createImage(attributes?: Array<[string, string]>): SVGImageElement;
    /**
     * Creates an SVG point with the specified coordinates.
     * @param x
     * @param y
     */
    static createPoint(x: number, y: number): SVGPoint;
    /**
     * Creates an SVG path with the specified shape (d).
     * @param d - path shape
     * @param attributes - additional attributes.
     */
    static createPath(d: string, attributes?: Array<[string, string]>): SVGPathElement;
    /**
     * Creates an SVG text element.
     * @param attributes - additional attributes.
     */
    static createForeignObject(attributes?: Array<[string, string]>): SVGForeignObjectElement;
    /**
     * Returns local coordinates relative to the provided `localRoot` of a client (screen) point.
     * @param localRoot relative coordinate root
     * @param x horizontal client coordinate
     * @param y vertical client coordinate
     * @param zoomLevel zoom level
     * @returns local coordinates relative to `localRoot`
     */
    static clientToLocalCoordinates(localRoot: SVGElement | undefined, x: number, y: number, zoomLevel?: number): IPoint;
    /**
     * Creates an SVG image element from a supplied inner SVG markup string.
     * @param stringSvg SVG markup (without the root svg tags)
     * @returns SVG image element
     */
    static createSvgFromString(stringSvg: string): SVGSVGElement;
    /**
     * Creates an SVG filter element.
     * @param id filter id
     * @param attributes other filter element attributes
     * @param innerHTML filter definition as string
     * @returns filter element
     */
    static createFilter(id: string, attributes?: Array<[string, string]>, innerHTML?: string): SVGFilterElement;
}

/**
 * Manages commercial licenses.
 * @ignore
 */
declare class Activator {
    private static keys;
    private static keyAddListeners;
    /**
     * Add a license key
     * @param product product identifier.
     * @param key license key sent to you after purchase.
     */
    static addKey(product: string, key: string): void;
    /**
     * Add a function to be called when license key is added.
     * @param listener
     */
    static addKeyAddListener(listener: () => void): void;
    /**
     * Remove a function called when key is added.
     * @param listener
     */
    static removeKeyAddListener(listener: () => void): void;
    /**
     * Returns true if the product is commercially licensed.
     * @param product product identifier.
     */
    static isLicensed(product: string): boolean;
}

/**
 * Represents marker's state used to save and restore state.
 *
 * The state can then be serialized and stored for future use like to continue
 * annotation in the future, display it in a viewer or render as a static image.
 */
interface MarkerBaseState {
    /**
     * Marker's type name.
     */
    typeName: string;
    /**
     * Additional information about the marker.
     */
    notes?: string;
    /**
     * Marker's stroke (outline) color.
     */
    strokeColor?: string;
    /**
     * Marker's stroke (outline) width.
     */
    strokeWidth?: number;
    /**
     * Marker's stroke (outline) dash array.
     */
    strokeDasharray?: string;
    /**
     * Marker's opacity.
     */
    opacity?: number;
}

/**
 * Represents the state of the annotation.
 *
 * The state is returned by {@link Editor!MarkerArea.getState | MarkerArea.getState()} and can be used to
 * restore the annotation in {@link Editor!MarkerArea | MarkerArea}
 * with {@link Editor!MarkerArea.restoreState | MarkerArea.restoreState()}
 * or passed to {@link Viewer!MarkerView.show | MakerView.show()}
 * or {@link Renderer!Renderer.rasterize | Renderer.rasterize()}.
 */
interface AnnotationState {
    /**
     * Version of the annotation state format.
     *
     * Equals to 3 for the current version.
     */
    version?: number;
    /**
     * Width of the annotation.
     */
    width: number;
    /**
     * Height of the annotation.
     */
    height: number;
    /**
     * Default SVG filter to apply to markers in the annotation.
     * (e.g. drop shadow, outline, glow)
     *
     * @since 3.2.0
     */
    defaultFilter?: string;
    /**
     * Array of marker states for markers in the annotation.
     */
    markers: MarkerBaseState[];
}

/**
 * Represents a stage in a marker's lifecycle.
 *
 * Most markers are created immediately after the user clicks on the canvas.
 * However, some markers are only finished creating after additional interactions.
 */
type MarkerStage = 'creating' | 'normal';
/**
 * Base class for all markers.
 *
 * When creating custom marker types usually you will want to extend one of the derived classes.
 * However, if you cannot find a suitable base class, you can and you should extend this class.
 *
 * @summary Base class for all markers.
 * @group Markers
 */
declare class MarkerBase {
    /**
     * Marker type name.
     *
     * It's important to set this in each derived class. This value is used to identify marker types
     * when restoring marker state and other scenarios.
     */
    static typeName: string;
    /**
     * Returns marker type name for the object instance.
     */
    get typeName(): string;
    /**
     * Marker type title (display name) used for accessibility and other attributes.
     */
    static title: string;
    /**
     * When true, the default filter is applied to the marker's visual.
     *
     * @since 3.2.0
     */
    static applyDefaultFilter: boolean;
    /**
     * SVG container object holding the marker's visual.
     *
     * It is created and passed to the constructor by marker editor or viewer when creating the marker.
     */
    protected _container: SVGGElement;
    /**
     * SVG container object holding the marker's visual.
     */
    /**
     * SVG container object holding the marker's visual.
     */
    get container(): SVGGElement;
    /**
     * Additional information about the marker.
     *
     * Generally, this isn't used for anything functional.
     * However, in a derived type it could be used for storing arbitrary data with no need to create extra properties and state types.
     */
    notes?: string;
    /**
     * The default marker size when the marker is created with a click (without dragging).
     */
    defaultSize: ISize;
    /**
     * Marker lifecycle stage.
     *
     * Most markers are created immediately after the user clicks on the canvas (`normal`).
     * However, some markers are only finished creating after additional interactions (`creating`).
     */
    stage: MarkerStage;
    /**
     * Stroke (outline) color of the marker.
     */
    protected _strokeColor: string;
    /**
     * Stroke (outline) color of the marker.
     *
     * In a derived class override {@link applyStrokeColor} to apply the color to the marker's visual.
     */
    get strokeColor(): string;
    set strokeColor(color: string);
    /**
     * Applies the stroke color to the marker's visual.
     *
     * Override this method in a derived class to apply the color to the marker's visual.
     */
    protected applyStrokeColor(): void;
    /**
     * Fill color of the marker.
     */
    protected _fillColor: string;
    /**
     * Fill color of the marker.
     *
     * In a derived class override {@link applyFillColor} to apply the color to the marker's visual.
     */
    get fillColor(): string;
    set fillColor(color: string);
    /**
     * Applies the fill color to the marker's visual.
     *
     * Override this method in a derived class to apply the color to the marker's visual.
     */
    protected applyFillColor(): void;
    /**
     * Stroke (outline) width of the marker.
     */
    protected _strokeWidth: number;
    /**
     * Stroke (outline) width of the marker.
     *
     * In a derived class override {@link applyStrokeWidth} to apply the width to the marker's visual.
     */
    get strokeWidth(): number;
    set strokeWidth(value: number);
    /**
     * Applies the stroke width to the marker's visual.
     *
     * Override this method in a derived class to apply the width to the marker's visual.
     */
    protected applyStrokeWidth(): void;
    /**
     * Stroke (outline) dash array of the marker.
     */
    protected _strokeDasharray: string;
    /**
     * Stroke (outline) dash array of the marker.
     *
     * In a derived class override {@link applyStrokeDasharray} to apply the dash array to the marker's visual.
     */
    get strokeDasharray(): string;
    set strokeDasharray(value: string);
    /**
     * Applies the stroke dash array to the marker's visual.
     *
     * Override this method in a derived class to apply the dash array to the marker's visual.
     */
    protected applyStrokeDasharray(): void;
    /**
     * Opacity of the marker.
     */
    protected _opacity: number;
    /**
     * Opacity of the marker.
     *
     * In a derived class override {@link applyOpacity} to apply the opacity to the marker's visual.
     */
    get opacity(): number;
    set opacity(value: number);
    /**
     * Applies the opacity to the marker's visual.
     *
     * Override this method in a derived class to apply the opacity to the marker's visual
     */
    protected applyOpacity(): void;
    /**
     * Creates a new marker object.
     *
     * @param container - SVG container object holding the marker's visual.
     */
    constructor(container: SVGGElement);
    /**
     * Returns true if passed SVG element belongs to the marker. False otherwise.
     *
     * @param el - target element.
     * @returns true if the element belongs to the marker.
     */
    ownsTarget(el: EventTarget): boolean;
    /**
     * Disposes the marker and cleans up.
     */
    dispose(): void;
    protected addMarkerVisualToContainer(element: SVGElement): void;
    /**
     * When overridden in a derived class, represents a preliminary outline for markers that can be displayed before the marker is actually created.
     * @returns SVG path string.
     */
    getOutline(): string;
    /**
     * Returns current marker state that can be restored in the future.
     */
    getState(): MarkerBaseState;
    /**
     * Restores previously saved marker state.
     *
     * @param state - previously saved state.
     */
    restoreState(state: MarkerBaseState): void;
    /**
     * Scales marker. Used after resize.
     *
     * @param scaleX - horizontal scale
     * @param scaleY - vertical scale
     */
    scale(scaleX: number, scaleY: number): void;
    /**
     * Returns markers bounding box.
     *
     * Override to return a custom bounding box.
     *
     * @returns rectangle fitting the marker.
     */
    getBBox(): DOMRect;
}

/**
 * Represents a state snapshot of a RectangularBoxMarkerBase.
 */
interface RectangularBoxMarkerBaseState extends MarkerBaseState {
    /**
     * x coordinate of the top-left corner.
     */
    left: number;
    /**
     * y coordinate of the top-left corner.
     */
    top: number;
    /**
     * Marker's width.
     */
    width: number;
    /**
     * Marker's height.
     */
    height: number;
    /**
     * Marker's rotation angle.
     */
    rotationAngle: number;
    /**
     * Visual transform matrix.
     *
     * Used to correctly position and rotate marker.
     */
    visualTransformMatrix?: ITransformMatrix;
    /**
     * Container transform matrix.
     *
     * Used to correctly position and rotate marker.
     */
    containerTransformMatrix?: ITransformMatrix;
}

/**
 * RectangularBoxMarkerBase is a base class for all marker's that conceptually fit into a rectangle
 * such as all rectangle markers, ellipse, text and callout markers.
 *
 * @summary Base class for all markers that conceptually fit into a rectangle.
 * @group Markers
 */
declare class RectangularBoxMarkerBase extends MarkerBase {
    /**
     * x coordinate of the top-left corner.
     */
    left: number;
    /**
     * y coordinate of the top-left corner.
     */
    top: number;
    /**
     * Marker width.
     */
    width: number;
    /**
     * Marker height.
     */
    height: number;
    /**
     * Marker's rotation angle.
     */
    rotationAngle: number;
    /**
     * x coordinate of the marker's center.
     */
    get centerX(): number;
    /**
     * y coordinate of the marker's center.
     */
    get centerY(): number;
    private _visual?;
    /**
     * Container for the marker's visual.
     */
    protected get visual(): SVGGraphicsElement | undefined;
    protected set visual(value: SVGGraphicsElement);
    constructor(container: SVGGElement);
    /**
     * Moves visual to the specified coordinates.
     * @param point - coordinates of the new top-left corner of the visual.
     */
    moveVisual(point: IPoint): void;
    /**
     * Adjusts marker's size.
     */
    setSize(): void;
    /**
     * Rotates marker around the center.
     * @param point - coordinates of the rotation point.
     */
    rotate(point: IPoint): void;
    private applyRotation;
    /**
     * Returns point coordinates based on the actual screen coordinates and marker's rotation.
     * @param point - original pointer coordinates
     */
    rotatePoint(point: IPoint): IPoint;
    /**
     * Returns original point coordinates based on coordinates with rotation applied.
     * @param point - rotated point coordinates.
     */
    unrotatePoint(point: IPoint): IPoint;
    getOutline(): string;
    getState(): RectangularBoxMarkerBaseState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
    getBBox(): DOMRect;
}

/**
 * Shape outline marker is a base class for all markers that represent a shape outline.
 *
 * @summary Base class for shape outline (unfilled shape) markers.
 * @group Markers
 */
declare class ShapeOutlineMarkerBase extends RectangularBoxMarkerBase {
    static title: string;
    protected applyStrokeColor(): void;
    protected applyStrokeWidth(): void;
    protected applyStrokeDasharray(): void;
    protected applyOpacity(): void;
    constructor(container: SVGGElement);
    ownsTarget(el: EventTarget): boolean;
    protected getPath(width?: number, height?: number): string;
    getOutline(): string;
    /**
     * Creates marker's visual.
     */
    createVisual(): void;
    /**
     * Adjusts marker's visual according to the current state
     * (color, width, etc.).
     */
    adjustVisual(): void;
    setSize(): void;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Represents outline shape's state.
 */
interface ShapeOutlineMarkerBaseState extends RectangularBoxMarkerBaseState {
}

/**
 * Represents filled shape's state.
 */
interface ShapeMarkerBaseState extends ShapeOutlineMarkerBaseState {
    /**
     * Marker's fill color.
     */
    fillColor: string;
}

/**
 * Base class for filled shape markers.
 *
 * @summary Base class for filled shape markers.
 * @group Markers
 */
declare abstract class ShapeMarkerBase extends ShapeOutlineMarkerBase {
    static title: string;
    /**
     * Marker's fill color.
     */
    protected _fillColor: string;
    /**
     * Applies the fill color to the marker's visual.
     *
     * If needed, override this method in a derived class to apply the color to the marker's visual.
     */
    protected applyFillColor(): void;
    constructor(container: SVGGElement);
    createVisual(): void;
    getState(): ShapeMarkerBaseState;
    restoreState(state: MarkerBaseState): void;
}

/**
 * Frame marker represents unfilled rectangle shape.
 *
 * @summary Unfilled rectangle marker.
 * @group Markers
 */
declare class FrameMarker extends ShapeOutlineMarkerBase {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
    protected getPath(width?: number, height?: number): string;
}

/**
 * Represents base state for line-style markers.
 */
interface LinearMarkerBaseState extends MarkerBaseState {
    /**
     * x coordinate for the first end-point.
     */
    x1: number;
    /**
     * y coordinate for the first end-point.
     */
    y1: number;
    /**
     * x coordinate for the second end-point.
     */
    x2: number;
    /**
     * y coordinate for the second end-point.
     */
    y2: number;
}

/**
 * Base class for line-like markers.
 *
 * Use one of the derived classes.
 *
 * @summary Base class for line-like markers.
 * @group Markers
 */
declare class LinearMarkerBase extends MarkerBase {
    /**
     * x coordinate of the first end-point
     */
    x1: number;
    /**
     * y coordinate of the first end-point
     */
    y1: number;
    /**
     * x coordinate of the second end-point
     */
    x2: number;
    /**
     * y coordinate of the second end-point
     */
    y2: number;
    /**
     * Marker's main visual.
     */
    protected visual: SVGGraphicsElement | undefined;
    /**
     * Wider invisible visual to make it easier to select and manipulate the marker.
     */
    protected selectorVisual: SVGGraphicsElement | undefined;
    /**
     * Visible visual of the marker.
     */
    protected visibleVisual: SVGGraphicsElement | undefined;
    /**
     * Line visual of the marker.
     */
    protected lineVisual: SVGGraphicsElement | undefined;
    /**
     * Start terminator (ending) visual of the marker.
     */
    protected startTerminatorVisual: SVGGraphicsElement | undefined;
    /**
     * End terminator (ending) visual of the marker.
     */
    protected endTerminatorVisual: SVGGraphicsElement | undefined;
    protected applyStrokeColor(): void;
    protected applyStrokeWidth(): void;
    protected applyStrokeDasharray(): void;
    protected applyOpacity(): void;
    constructor(container: SVGGElement);
    ownsTarget(el: EventTarget): boolean;
    /**
     * The path representing the line part of the marker visual.
     *
     * When implemented in derived class should return SVG path for the marker.
     *
     * @returns SVG path for the marker.
     */
    protected getPath(): string;
    /**
     * The path representing the start terminator (ending) part of the marker visual.
     * @returns SVG path
     */
    protected getStartTerminatorPath(): string;
    /**
     * The path representing the end terminator (ending) part of the marker visual.
     * @returns SVG path
     */
    protected getEndTerminatorPath(): string;
    /**
     * Creates marker's visual.
     */
    createVisual(): void;
    /**
     * Adjusts marker visual after manipulation when needed.
     */
    adjustVisual(): void;
    getState(): LinearMarkerBaseState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Line marker represents a simple straight line.
 *
 * @summary Line marker.
 * @group Markers
 */
declare class LineMarker extends LinearMarkerBase {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
    protected getPath(): string;
}

/**
 * Arrow type.
 *
 * Specifies whether the arrow should be drawn at the start, end, both ends or none.
 */
type ArrowType = 'both' | 'start' | 'end' | 'none';
/**
 * Represents the state of the arrow marker.
 */
interface ArrowMarkerState extends LinearMarkerBaseState {
    arrowType: ArrowType;
}

/**
 * Arrow marker represents a line with arrow heads at the ends.
 *
 * @summary A line with arrow heads at the ends.
 *
 * @group Markers
 */
declare class ArrowMarker extends LineMarker {
    static typeName: string;
    static title: string;
    private _arrowType;
    /**
     * Type of the arrow.
     *
     * Specify whether the arrow should be drawn at the start, end, both ends or none.
     */
    get arrowType(): ArrowType;
    set arrowType(value: ArrowType);
    constructor(container: SVGGElement);
    private getArrowProperties;
    protected getStartTerminatorPath(): string;
    protected getEndTerminatorPath(): string;
    protected applyStrokeWidth(): void;
    getState(): ArrowMarkerState;
    restoreState(state: MarkerBaseState): void;
}

/**
 * Represents a measurement marker.
 *
 * Measurement marker is a line with two vertical bars at the ends.
 *
 * @summary A line with two vertical bars at the ends.
 * @group Markers
 */
declare class MeasurementMarker extends LineMarker {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
    protected getStartTerminatorPath(): string;
    protected getEndTerminatorPath(): string;
    private getTerminatorProperties;
    protected applyStrokeWidth(): void;
}

/**
 * Represents polygon marker's state used to save and restore state.
 */
interface PolygonMarkerState extends MarkerBaseState {
    /**
     * Polygon points.
     */
    points: Array<IPoint>;
}

/**
 * Polygon marker is a multi-point marker that represents a polygon.
 *
 * @summary Polygon marker.
 * @group Markers
 */
declare class PolygonMarker extends MarkerBase {
    static typeName: string;
    static title: string;
    /**
     * Marker's points.
     */
    points: IPoint[];
    /**
     * Marker's main visual.
     */
    visual: SVGGraphicsElement | undefined;
    selectorVisual: SVGGElement | undefined;
    selectorVisualLines: SVGLineElement[];
    visibleVisual: SVGGraphicsElement | undefined;
    protected applyStrokeColor(): void;
    protected applyFillColor(): void;
    protected applyStrokeWidth(): void;
    protected applyStrokeDasharray(): void;
    protected applyOpacity(): void;
    constructor(container: SVGGElement);
    ownsTarget(el: EventTarget): boolean;
    /**
     * Returns SVG path string for the polygon.
     *
     * @returns Path string for the polygon.
     */
    protected getPath(): string;
    /**
     * Creates marker's main visual.
     */
    createVisual(): void;
    /**
     * Creates selector visual.
     *
     * Selector visual is a transparent wider visual that allows easier selection of the marker.
     */
    private createSelectorVisual;
    /**
     * Adjusts marker visual after manipulation when needed.
     */
    adjustVisual(): void;
    private adjustSelectorVisual;
    private addSelectorLine;
    getState(): PolygonMarkerState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Represents the state of a freehand marker.
 */
interface FreehandMarkerState extends MarkerBaseState {
    /**
     * Points of the freehand line.
     */
    points: Array<IPoint>;
}

/**
 * Freehand marker represents a hand drawing.
 *
 * Unlike v2 in v3 freehand marker is represented by an SVG path element.
 * This means that the line properties like stroke color, width, dasharray, etc.
 * can be modified after drawing.
 *
 * @summary Freehand drawing marker.
 * @group Markers
 */
declare class FreehandMarker extends MarkerBase {
    static typeName: string;
    static title: string;
    static applyDefaultFilter: boolean;
    /**
     * Points of the freehand line.
     */
    points: IPoint[];
    /**
     * Marker's main visual.
     */
    visual: SVGGraphicsElement | undefined;
    /**
     * Wider invisible visual to make it easier to select and manipulate the marker.
     */
    protected selectorVisual: SVGGraphicsElement | undefined;
    /**
     * Visible visual of the marker.
     */
    visibleVisual: SVGGraphicsElement | undefined;
    protected applyStrokeColor(): void;
    protected applyStrokeWidth(): void;
    protected applyStrokeDasharray(): void;
    protected applyOpacity(): void;
    constructor(container: SVGGElement);
    ownsTarget(el: EventTarget): boolean;
    /**
     * Returns SVG path string representing the freehand line.
     *
     * @returns SVG path string representing the freehand line.
     */
    protected getPath(): string;
    /**
     * Creates the visual elements comprising the marker's visual.
     */
    createVisual(): void;
    /**
     * Adjusts marker visual after manipulation or with new points.
     */
    adjustVisual(): void;
    getState(): FreehandMarkerState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Font size settings.
 */
interface FontSize {
    /**
     * Number of {@link units}.
     */
    value: number;
    /**
     * Units the {@link value} represents.
     */
    units: string;
    /**
     * Value increment/decrement step for controls cycling through the size values.
     */
    step: number;
}

/**
 * TextBlock represents a block of text used across all text-based markers.
 */
declare class TextBlock {
    /**
     * Fired when text size changes.
     *
     * @group Events
     */
    onTextSizeChanged?: (textBlock: TextBlock) => void;
    private _text;
    /**
     * Returns the text block's text.
     */
    get text(): string;
    /**
     * Sets the text block's text.
     */
    set text(value: string);
    /**
     * Text block's horizontal offset from the automatically calculated position.
     */
    offsetX: number;
    /**
     * Text block's vertical offset from the automatically calculated position.
     */
    offsetY: number;
    private _boundingBox;
    /**
     * Returns the bounding box where text should fit and/or be anchored.
     */
    get boundingBox(): DOMRect;
    /**
     * Sets the bounding box where text should fit and/or be anchored.
     */
    set boundingBox(value: DOMRect);
    private _labelBackground;
    /**
     * Returns the background rectangle (behind the text).
     */
    get labelBackground(): SVGRectElement;
    private _textElement;
    /**
     * Returns the text block's text element.
     */
    get textElement(): SVGTextElement;
    private _color;
    /**
     * Sets the text color.
     */
    set color(value: string);
    /**
     * Returns the text color.
     */
    get color(): string;
    private _fontFamily;
    /**
     * Returns the text's font family.
     */
    get fontFamily(): string;
    /**
     * Sets the text's font family.
     */
    set fontFamily(value: string);
    private _fontSize;
    /**
     * Returns the text's font size.
     */
    get fontSize(): FontSize;
    /**
     * Sets the text's font size.
     */
    set fontSize(value: FontSize);
    /**
     * Creates a text block
     * @param text initial text
     */
    constructor(text?: string);
    /**
     * Returns true if the text block contains the supplied element.
     * @param el element to test.
     * @returns true if the element belongs to the text block, false otherwise.
     */
    ownsTarget(el: EventTarget): boolean;
    private setupTextElement;
    private wrapText;
    wordWrap: boolean;
    private prevWrappedText;
    /**
     * Renders text within the text block according to its settings.
     */
    renderText(): Promise<void>;
    private applyFontStyles;
    private _textSize?;
    /**
     * Returns the size of the rectangle containing the text block's text.
     */
    get textSize(): DOMRect | undefined;
    /**
     * Positions the text within the text block.
     * @param textBlock
     */
    positionText(textBlock?: TextBlock): void;
    /**
     * Makes the text block content visible.
     */
    show(): void;
    /**
     * Hides the text block content.
     */
    hide(): void;
    /**
     * Shows the text block's dashed outline.
     */
    showControlBox(): void;
    /**
     * Hides the text block's dashed outline.
     */
    hideControlBox(): void;
}

/**
 * Represents a state snapshot of a TextMarker.
 */
interface TextMarkerState extends RectangularBoxMarkerBaseState {
    /**
     * Text color.
     */
    color: string;
    /**
     * Font family.
     */
    fontFamily: string;
    /**
     * Font size.
     */
    fontSize: FontSize;
    /**
     * Text content.
     */
    text: string;
}

/**
 * Text marker.
 *
 * Used to represent a text block as well a base class for other text-based markers.
 *
 * @summary Text marker.
 * @group Markers
 */
declare class TextMarker extends RectangularBoxMarkerBase {
    static typeName: string;
    static title: string;
    /**
     * Default text for the marker type.
     */
    protected static DEFAULT_TEXT: string;
    /**
     * Callback to be called when the text size changes.
     */
    onSizeChanged?: (textMarker: TextMarker) => void;
    private _color;
    /**
     * Returns markers's text color.
     */
    get color(): string;
    /**
     * Sets the markers's text color.
     */
    set color(value: string);
    private _fontFamily;
    /**
     * Returns the markers's font family.
     */
    get fontFamily(): string;
    /**
     * Sets the markers's font family.
     */
    set fontFamily(value: string);
    private _fontSize;
    /**
     * Returns the marker's font size.
     */
    get fontSize(): FontSize;
    /**
     * Sets the marker's font size.
     */
    set fontSize(value: FontSize);
    /**
     * Returns the default text for the marker type.
     * @returns marker type's default text.
     */
    protected getDefaultText(): string;
    private _text;
    /**
     * Returns the marker's text.
     */
    get text(): string;
    /**
     * Sets the marker's text.
     */
    set text(value: string);
    /**
     * Text padding from the bounding box.
     */
    padding: number;
    /**
     * Text's bounding box where text should fit and/or be anchored to.
     */
    textBoundingBox: DOMRect;
    /**
     * Text block handling the text rendering.
     */
    textBlock: TextBlock;
    constructor(container: SVGGElement);
    protected applyOpacity(): void;
    /**
     * Creates marker's visual.
     */
    createVisual(): void;
    /**
     * Adjusts marker's visual according to the current state.
     */
    adjustVisual(): void;
    ownsTarget(el: EventTarget): boolean;
    /**
     * Sets the text bounding box.
     */
    protected setTextBoundingBox(): void;
    /**
     * Sets (adjusts) the marker's size.
     */
    setSize(): void;
    /**
     * Sets the marker's size based on the text size.
     */
    protected setSizeFromTextSize(): void;
    private textSizeChanged;
    /**
     * Sets the text color.
     * @param color text color
     */
    setColor(color: string): void;
    /**
     * Sets the font family.
     * @param font font family string
     */
    setFont(font: string): void;
    /**
     * Sets the font size.
     * @param fontSize font size
     */
    setFontSize(fontSize: FontSize): void;
    /**
     * Hides the marker's visual.
     *
     * Used when editing the text.
     */
    hideVisual(): void;
    /**
     * Shows the marker's visual.
     *
     * Eg. when done editing the text.
     */
    showVisual(): void;
    getState(): TextMarkerState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Cover marker is a filled rectangle marker.
 *
 * A typical use case is to cover some area of the image with a colored rectangle as a "redaction".
 *
 * @summary Filled rectangle marker.
 * @group Markers
 */
declare class CoverMarker extends ShapeMarkerBase {
    static typeName: string;
    static title: string;
    static applyDefaultFilter: boolean;
    constructor(container: SVGGElement);
    protected getPath(width?: number, height?: number): string;
}

/**
 * Highlight marker is a semi-transparent rectangular marker.
 *
 * @summary Semi-transparent rectangular marker.
 * @group Markers
 */
declare class HighlightMarker extends ShapeMarkerBase {
    static typeName: string;
    static title: string;
    static applyDefaultFilter: boolean;
    constructor(container: SVGGElement);
    protected getPath(width?: number, height?: number): string;
}

/**
 * Represents the state of a callout marker.
 */
interface CalloutMarkerState extends TextMarkerState, ShapeMarkerBaseState {
    /**
     * Coordinates of the position of the tip of the callout.
     */
    tipPosition: IPoint;
}

/**
 * Callout marker is a text-based marker with a callout outline with a tip that can point to specific place
 * on the underlying image or annotation.
 *
 * @summary Text-based marker with a callout outline with a tip that can point to specific place
 * on the underlying image or annotation.
 *
 * @group Markers
 */
declare class CalloutMarker extends TextMarker {
    static typeName: string;
    static title: string;
    private _tipPosition;
    /**
     * Coordinates of the position of the tip of the callout.
     */
    get tipPosition(): IPoint;
    set tipPosition(value: IPoint);
    private tipBase1Position;
    private tipBase2Position;
    private _calloutVisual;
    constructor(container: SVGGElement);
    protected applyStrokeColor(): void;
    protected applyStrokeWidth(): void;
    protected applyStrokeDasharray(): void;
    protected applyOpacity(): void;
    protected applyFillColor(): void;
    /**
     * Returns the SVG path string for the callout outline.
     *
     * @returns Path string for the callout outline.
     */
    protected getPath(): string;
    private setTipPoints;
    createVisual(): void;
    adjustVisual(): void;
    ownsTarget(el: EventTarget): boolean;
    getState(): CalloutMarkerState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Ellipse frame marker represents unfilled circle/ellipse shape.
 *
 * @summary Unfilled ellipse marker.
 * @group Markers
 */
declare class EllipseFrameMarker extends ShapeOutlineMarkerBase {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
    protected getPath(width?: number, height?: number): string;
}

/**
 * Ellipse marker is a filled ellipse marker.
 *
 * @summary Filled ellipse marker.
 * @group Markers
 */
declare class EllipseMarker extends ShapeMarkerBase {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
    protected getPath(width?: number, height?: number): string;
}

/**
 * The type of image (svg or bitmap).
 *
 * Used in {@link Core!ImageMarkerBase | ImageMarkerBase } and its descendants.
 */
type ImageType = 'svg' | 'bitmap';
/**
 * Represents image marker's state.
 */
interface ImageMarkerBaseState extends RectangularBoxMarkerBaseState {
    /**
     * Type of the image: SVG or bitmap.
     */
    imageType?: ImageType;
    /**
     * SVG markup of the SVG image.
     */
    svgString?: string;
    /**
     * Image source (URL or base64 encoded image).
     */
    imageSrc?: string;
}

/**
 * Base class for image markers.
 *
 * This class isn't meant to be used directly. Use one of the derived classes instead.
 *
 * @summary Image marker base class.
 * @group Markers
 */
declare class ImageMarkerBase extends RectangularBoxMarkerBase {
    static title: string;
    /**
     * Main SVG or image element of the marker.
     */
    protected SVGImage?: SVGSVGElement | SVGImageElement;
    /**
     * Type of the image: SVG or bitmap.
     */
    protected imageType: ImageType;
    /**
     * For SVG images this holds the SVG markup of the image.
     */
    protected _svgString?: string;
    /**
     * For SVG images this holds the SVG markup of the image.
     */
    get svgString(): string | undefined;
    set svgString(value: string | undefined);
    /**
     * For bitmap images this holds the base64 encoded image.
     */
    protected _imageSrc?: string;
    /**
     * For bitmap images this holds the base64 encoded image.
     *
     * @remarks
     * Technically this could be any URL but due to browser security constraints
     * an external image will almost certainly cause bitmap rendering of the image to fail.
     *
     * In cases you know you will never render the annotation as a static image,
     * it should be safe to use external URLs. Otherwise, use base64 encoded images
     * like 'data:image/png;base64,...'.
     */
    get imageSrc(): string | undefined;
    set imageSrc(value: string | undefined);
    /**
     * Natural (real) width of the image.
     */
    protected naturalWidth: number;
    /**
     * Natural (real) height of the image.
     */
    protected naturalHeight: number;
    constructor(container: SVGGElement);
    protected applyOpacity(): void;
    /**
     * Creates the image element based on the image type and source.
     */
    protected createImage(): void;
    /**
     * Creates marker's visual, including its image element.
     */
    createVisual(): void;
    /**
     * Adjusts marker's visual according to the current state
     * (color, width, etc.).
     */
    adjustVisual(): void;
    /**
     * Adjusts the image size and position.
     */
    adjustImage(): void;
    private isDescendant;
    ownsTarget(el: EventTarget): boolean;
    setSize(): void;
    getState(): ImageMarkerBaseState;
    protected applyStrokeColor(): void;
    restoreState(state: ImageMarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Used to represent user-set images.
 *
 * Use this marker to display custom images at runtime.
 * For example, you can use this type to represent emojis selected in an emoji picker.
 *
 * @summary Custom image marker.
 * @group Markers
 */
declare class CustomImageMarker extends ImageMarkerBase {
    static typeName: string;
    static title: string;
}

/**
 * Check mark marker.
 *
 * Represents a check mark image marker. Can be used to quickly mark something as correct, or
 * similar use cases.
 *
 * @summary Check mark image marker.
 * @group Markers
 */
declare class CheckImageMarker extends ImageMarkerBase {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
}

/**
 * X mark image marker.
 *
 * @summary X (crossed) image marker.
 * @group Markers
 */
declare class XImageMarker extends ImageMarkerBase {
    static typeName: string;
    static title: string;
    constructor(container: SVGGElement);
}

/**
 * Represents the state of a caption frame marker.
 */
interface CaptionFrameMarkerState extends TextMarkerState, ShapeMarkerBaseState {
}

/**
 * Caption frame marker is a product of a frame (rectangle) and a text caption that goes with it.
 *
 * @summary A product of a frame (rectangle) and a text caption that goes with it.
 *
 * @group Markers
 */
declare class CaptionFrameMarker extends TextMarker {
    static typeName: string;
    static title: string;
    private _outerFrameVisual;
    private _captionFrameVisual;
    private _frameVisual;
    constructor(container: SVGGElement);
    protected applyStrokeColor(): void;
    protected applyStrokeWidth(): void;
    protected applyStrokeDasharray(): void;
    protected applyOpacity(): void;
    protected applyFillColor(): void;
    /**
     * Returns the SVG path strings for the frame and the caption background.
     *
     * @param width
     * @param height
     * @returns SVG path strings for the frame and the caption background.
     */
    protected getPaths(width?: number, height?: number): {
        frame: string;
        caption: string;
    };
    createVisual(): void;
    adjustVisual(): void;
    /**
     * Adjusts text position inside the caption frame.
     */
    protected adjustTextPosition(): void;
    /**
     * Adjusts frame visual according to the current marker properties.
     */
    protected adjustFrameVisual(): void;
    ownsTarget(el: EventTarget): boolean;
    setSize(): void;
    protected setSizeFromTextSize(): void;
    /**
     * Hides the marker visual.
     *
     * Used by the editor to hide rendered marker while editing the text.
     */
    hideVisual(): void;
    /**
     * Shows the marker visual.
     *
     * Used by the editor to show rendered marker after editing the text.
     */
    showVisual(): void;
    getState(): CaptionFrameMarkerState;
    restoreState(state: MarkerBaseState): void;
    scale(scaleX: number, scaleY: number): void;
}

interface CurveMarkerState extends LinearMarkerBaseState {
    /**
     * x coordinate for the curve control point.
     */
    curveX: number;
    /**
     * y coordinate for the curve control point.
     */
    curveY: number;
}

/**
 * Curve marker represents a curved line.
 *
 * @summary Curve marker.
 * @group Markers
 */
declare class CurveMarker extends LineMarker {
    static typeName: string;
    static title: string;
    /**
     * x coordinate for the curve control point.
     */
    curveX: number;
    /**
     * y coordinate for the curve control point.
     */
    curveY: number;
    constructor(container: SVGGElement);
    protected getPath(): string;
    getState(): CurveMarkerState;
    restoreState(state: CurveMarkerState): void;
}

/**
 * Highlighter marker imitates a freeform highlighter pen.
 *
 * @summary Semi-transparent freeform marker.
 * @group Markers
 * @since 3.2.0
 */
declare class HighlighterMarker extends FreehandMarker {
    static typeName: string;
    static title: string;
    static applyDefaultFilter: boolean;
    constructor(container: SVGGElement);
}

/**
 * A set of common SVG filters that can be used to make markers more legible
 * or just for visual effect.
 */
declare class SvgFilters {
    /**
     * Returns a set of default filters that can be used to make markers more legible.
     * @returns array of SVG filters.
     */
    static getDefaultFilterSet(): SVGFilterElement[];
}

/**
 * Properties for marker editor.
 */
interface MarkerEditorProperties<TMarkerType extends MarkerBase = MarkerBase> {
    /**
     * SVG container for the marker and editor elements.
     */
    container: SVGGElement;
    /**
     * HTML overlay container for editor's HTML elements (such as label text editor).
     */
    overlayContainer: HTMLDivElement;
    /**
     * Type of marker to create.
     */
    markerType: new (container: SVGGElement) => TMarkerType;
    /**
     * Previously created marker to edit.
     */
    marker?: TMarkerType;
}

/**
 * Represents marker's state (status) in time.
 */
type MarkerEditorState = 'new' | 'creating' | 'select' | 'move' | 'resize' | 'rotate' | 'edit';
/**
 * Marker creation style defines whether markers are created by drawing them or just dropping them on the canvas.
 */
type MarkerCreationStyle = 'draw' | 'drop';
/**
 * Base class for all marker editors.
 *
 * @typeParam TMarkerType - marker type the instance of the editor is for.
 *
 * @summary Base class for all marker editors.
 * @group Editors
 */
declare class MarkerBaseEditor<TMarkerType extends MarkerBase = MarkerBase> {
    /**
     * Marker type constructor.
     */
    protected _markerType: new (container: SVGGElement) => TMarkerType;
    /**
     * Marker creation style.
     *
     * Markers can either be created by drawing them or just dropping them on the canvas.
     */
    protected _creationStyle: MarkerCreationStyle;
    /**
     * Marker creation style.
     *
     * Markers can either be created by drawing them or just dropping them on the canvas.
     */
    get creationStyle(): MarkerCreationStyle;
    /**
     * Type guard for specific marker editor types.
     *
     * This allows to check if the editor is of a specific type which is useful for displaying type-specific UI.
     *
     * @typeParam T - specific marker editor type.
     * @param cls
     * @returns
     */
    is<T>(cls: new (...args: any[]) => T): this is T;
    /**
     * Marker instance.
     */
    protected _marker: TMarkerType;
    /**
     * Returns the marker instance.
     */
    get marker(): TMarkerType;
    /**
     * SVG container for the marker's and editor's visual elements.
     */
    protected _container: SVGGElement;
    /**
     * Returns the SVG container for the marker's and editor's visual elements.
     */
    get container(): SVGGElement;
    /**
     * Overlay container for HTML elements like text editors, etc.
     */
    protected _overlayContainer: HTMLDivElement;
    /**
     * Overlay container for HTML elements like text editors, etc.
     */
    get overlayContainer(): HTMLDivElement;
    /**
     * Editor's state.
     */
    protected _state: MarkerEditorState;
    /**
     * Gets editor's state.
     */
    get state(): MarkerEditorState;
    /**
     * Sets editor's state.
     */
    set state(value: MarkerEditorState);
    /**
     * SVG group holding editor's control box.
     */
    protected _controlBox: SVGGElement;
    /**
     * Method called when marker creation is finished.
     */
    onMarkerCreated?: <T extends MarkerBaseEditor<MarkerBase>>(editor: T) => void;
    /**
     * Method to call when marker state changes.
     */
    onStateChanged?: <T extends MarkerBaseEditor<MarkerBase>>(editor: T) => void;
    /**
     * Marker's state when it is selected
     */
    protected manipulationStartState?: string;
    /**
     * Is this marker selected?
     */
    protected _isSelected: boolean;
    /**
     * Returns true if the marker is currently selected
     */
    get isSelected(): boolean;
    /**
     * When set to true, a new marker of the same type is created immediately after the current one is finished.
     */
    protected _continuousCreation: boolean;
    /**
     * When set to true, a new marker of the same type is created immediately after the current one is finished.
     */
    get continuousCreation(): boolean;
    /**
     * Sets marker's stroke (outline) color.
     * @param color - color as string
     */
    set strokeColor(color: string);
    /**
     * Gets marker's stroke (outline) color.
     */
    get strokeColor(): string;
    /**
     * Sets marker's stroke (outline) width.
     * @param width - stroke width in pixels.
     */
    set strokeWidth(width: number);
    /**
     * Gets marker's stroke (outline) width.
     */
    get strokeWidth(): number;
    /**
     * Sets marker's stroke (outline) dash array.
     * @param dashes - dash array as string
     */
    set strokeDasharray(dashes: string);
    /**
     * Gets marker's stroke (outline) dash array.
     */
    get strokeDasharray(): string;
    /**
     * Sets marker's fill color.
     */
    set fillColor(color: string);
    /**
     * Gets marker's fill color.
     */
    get fillColor(): string;
    /**
     * Sets marker's opacity.
     */
    set opacity(value: number);
    /**
     * Gets marker's opacity.
     */
    get opacity(): number;
    /**
     * Sets marker's notes.
     */
    set notes(value: string | undefined);
    /**
     * Gets marker's notes.
     */
    get notes(): string | undefined;
    /**
     * Creates a new instance of marker editor.
     *
     * @param properties - marker editor properties.
     */
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    /**
     * Returns true if the marker or the editor owns supplied target element.
     *
     * @param el target element
     * @returns
     */
    ownsTarget(el: EventTarget | null): boolean;
    /**
     * Is this marker selected in a multi-selection?
     */
    protected isMultiSelected: boolean;
    /**
     * Selects this marker and displays appropriate selected marker UI.
     */
    select(multi?: boolean): void;
    /**
     * Deselects this marker and hides selected marker UI.
     */
    deselect(): void;
    /**
     * Handles pointer (mouse, touch, stylus, etc.) down event.
     *
     * @param point - event coordinates.
     * @param target - direct event target element.
     * @param ev - pointer event.
     */
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    /**
     * Handles pointer (mouse, touch, stylus, etc.) double click event.
     *
     * @param point - event coordinates.
     * @param target - direct event target element.
     * @param ev - pointer event.
     */
    dblClick(point: IPoint, target?: EventTarget, ev?: MouseEvent): void;
    /**
     * Handles marker manipulation (move, resize, rotate, etc.).
     *
     * @param point - event coordinates.
     * @param ev - pointer event.
     */
    manipulate(point: IPoint, ev?: PointerEvent): void;
    /**
     * Handles pointer (mouse, touch, stylus, etc.) up event.
     *
     * @param point - event coordinates.
     * @param ev - pointer event.
     */
    pointerUp(point: IPoint, ev?: PointerEvent): void;
    /**
     * Disposes the marker and clean's up.
     */
    dispose(): void;
    /**
     * Adjusts marker's control box.
     */
    protected adjustControlBox(): void;
    /**
     * Scales the marker and the editor.
     *
     * @param scaleX
     * @param scaleY
     */
    scale(scaleX: number, scaleY: number): void;
    /**
     * Called by a marker when its state could have changed.
     * Does a check if the state has indeed changed before firing the handler.
     */
    protected stateChanged(): void;
    /**
     * Returns marker's state that can be restored in the future.
     *
     * @returns
     */
    getState(): MarkerBaseState;
    /**
     * Restores previously saved marker state.
     *
     * @param state - previously saved state.
     */
    restoreState(state: MarkerBaseState): void;
}

/**
 * Marker area custom event types.
 */
interface MarkerAreaEventMap {
    /**
     * Marker area initialized.
     */
    areainit: CustomEvent<MarkerAreaEventData>;
    /**
     * Marker area shown.
     */
    areashow: CustomEvent<MarkerAreaEventData>;
    /**
     * Marker area state restored.
     */
    arearestorestate: CustomEvent<MarkerAreaEventData>;
    /**
     * Marker area focused.
     */
    areafocus: CustomEvent<MarkerAreaEventData>;
    /**
     * Marker area lost focus.
     */
    areablur: CustomEvent<MarkerAreaEventData>;
    /**
     * Marker area state changed.
     */
    areastatechange: CustomEvent<MarkerAreaEventData>;
    /**
     * Marker selected.
     */
    markerselect: CustomEvent<MarkerEditorEventData>;
    /**
     * Marker deselected.
     */
    markerdeselect: CustomEvent<MarkerEditorEventData>;
    /**
     * Marker creating.
     */
    markercreating: CustomEvent<MarkerEditorEventData>;
    /**
     * Marker created.
     */
    markercreate: CustomEvent<MarkerEditorEventData>;
    /**
     * Marker about to be deleted.
     */
    markerbeforedelete: CustomEvent<MarkerEditorEventData>;
    /**
     * Marker deleted.
     */
    markerdelete: CustomEvent<MarkerEditorEventData>;
    /**
     * Marker changed.
     */
    markerchange: CustomEvent<MarkerEditorEventData>;
}
/**
 * Marker area custom event data.
 */
interface MarkerAreaEventData {
    /**
     * {@link MarkerArea} instance.
     */
    markerArea: MarkerArea;
}
/**
 * Marker editor custom event data.
 */
interface MarkerEditorEventData extends MarkerAreaEventData {
    markerEditor: MarkerBaseEditor;
}
/**
 * @ignore
 */
type MarkerAreaMode = 'select' | 'create' | 'delete';
/**
 * Marker area web component is the main annotation editor component.
 *
 * @summary
 * The main annotation editor component.
 *
 * @group Components
 *
 * @example
 *
 * Import `MarkerArea` from `@markerjs/markerjs3`:
 *
 * ```js
 * import { MarkerArea } from '@markerjs/markerjs3';
 * ```
 *
 * In the code below we assume that you have an `HTMLImageElement` as `targetImage`. It can be a reference to an image you already have on the page or you can simply create it with something like this:
 *
 * ```js
 * const targetImg = document.createElement('img');
 * targetImg.src = './sample.jpg';
 * ```
 *
 * Now you just need to create an instance of `MarkerArea`, set its `targetImage` property and add it to the page:
 *
 * ```js
 * const markerArea = new MarkerArea();
 * markerArea.targetImage = targetImg;
 * editorContainerDiv.appendChild(markerArea);
 * ```
 *
 * To initiate creation of a marker you just call `createMarker()` and pass it the name (or type) of the marker you want to create. So, if you have a button with id `addFrameButton` you can make it create a new `FrameMarker` with something like this:
 *
 * ```js
 * document.querySelector("#addButton")!.addEventListener("click", () => {
 *   markerArea.createMarker("FrameMarker");
 * });
 * ```
 *
 * And whenever you want to save state (current annotation) you just call `getState()`:
 *
 * ```js
 * document.querySelector("#saveStateButton")!.addEventListener("click", () => {
 *   const state = markerArea.getState();
 *   console.log(state);
 * });
 * ```
 */
declare class MarkerArea extends HTMLElement {
    private _contentContainer?;
    private _canvasContainer?;
    private _overlayContainer;
    private _overlayContentContainer;
    private _mainCanvas?;
    private _groupLayer?;
    private _editingTarget?;
    private width;
    private height;
    private _targetWidth;
    /**
     * Returns the target image width.
     */
    get targetWidth(): number;
    /**
     * Sets the target image width.
     */
    set targetWidth(value: number);
    private _targetHeight;
    /**
     * Returns the target image height.
     */
    get targetHeight(): number;
    /**
     * Sets the target image height.
     */
    set targetHeight(value: number);
    private mode;
    private _logoUI?;
    private _isInitialized;
    private _currentMarkerEditor?;
    /**
     * Returns the currently active marker editor.
     */
    get currentMarkerEditor(): MarkerBaseEditor | undefined;
    private _selectedMarkerEditors;
    /**
     * Returns the currently selected marker editors.
     */
    get selectedMarkerEditors(): MarkerBaseEditor[];
    private _newMarkerOutline;
    private _targetImageLoaded;
    private _targetImage;
    /**
     * Returns the target image.
     */
    get targetImage(): HTMLImageElement | undefined;
    /**
     * Sets the target image.
     */
    set targetImage(value: HTMLImageElement | undefined);
    /**
     * The collection of available marker editor types.
     */
    markerEditors: Map<typeof MarkerBase, typeof MarkerBaseEditor<MarkerBase>>;
    /**
     * The collection of marker editors in the annotation.
     */
    editors: MarkerBaseEditor[];
    private _zoomLevel;
    /**
     * Returns the current zoom level.
     */
    get zoomLevel(): number;
    /**
     * Sets the current zoom level.
     */
    set zoomLevel(value: number);
    private prevPanPoint;
    private panTo;
    private undoRedoManager;
    private _defaultFilter?;
    /**
     * Returns the default SVG filter for the created markers.
     *
     * @since 3.2.0
     */
    get defaultFilter(): string | undefined;
    /**
     * Sets the default SVG filter for the created markers.
     *
     * @remarks
     * The filter should be a valid SVG filter string.
     *
     * In Chromium-based browsers and Firefox, you can use CSS filter strings
     *  e.g. "drop-shadow(2px 2px 2px black)". Unfortunately, at the time of
     * the implementation this doesn't work in Safari (meaning any browser on iOS as well).
     *
     * For cross-browser compatibility, version 3.3 introduces a set of default filters.
     * These are dropShadow, outline, and glow. You can use them by setting the defaultFilter
     * to "url(#dropShadow)", "url(#outline)", or "url(#glow)" respectively.
     *
     * @since 3.2.0
     */
    set defaultFilter(value: string | undefined);
    private _defsElement?;
    private _defs;
    constructor();
    private connectedCallback;
    private disconnectedCallback;
    private createLayout;
    private addMainCanvas;
    private addDefsToMainCanvas;
    private setMainCanvasSize;
    private setEditingTargetSize;
    private initOverlay;
    private addTargetImage;
    private addDefaultFilterDefs;
    /**
     * Registers a marker type and its editor to be available in the marker area.
     * @param markerType
     * @param editorType
     */
    registerMarkerType(markerType: typeof MarkerBase, editorType: typeof MarkerBaseEditor<MarkerBase>): void;
    /**
     * Creates a new marker of the specified type.
     * @param markerType
     * @returns
     */
    createMarker(markerType: typeof MarkerBase | string): MarkerBaseEditor<MarkerBase> | undefined;
    private addNewMarker;
    private markerCreated;
    private markerStateChanged;
    /**
     * Deletes a marker represented by the specified editor.
     * @param markerEditor
     */
    deleteMarker(markerEditor: MarkerBaseEditor): void;
    /**
     * Deselects all markers.
     */
    deleteSelectedMarkers(): void;
    /**
     * Sets the current editor and selects it.
     *
     * If `editor` is not supplied the current editor is unselected.
     *
     * @param editor
     */
    setCurrentEditor(editor?: MarkerBaseEditor): void;
    /**
     * Selects the specified editor without setting it as the current editor.
     * @param editor
     */
    selectEditor(editor: MarkerBaseEditor): void;
    /**
     * Deselects the specified editor (or all editors if not specified).
     * @param editor
     */
    deselectEditor(editor?: MarkerBaseEditor): void;
    private touchPoints;
    private leadPointerId?;
    private isDragging;
    private isSelecting;
    private isPanning;
    private _marqueeSelectOutline;
    private _marqueeSelectRect;
    private _manipulationStartX;
    private _manipulationStartY;
    private onCanvasPointerDown;
    private initializeMarqueeSelection;
    private onCanvasDblClick;
    private onPointerMove;
    private showOutline;
    private hideOutline;
    private onPointerUp;
    private finishMarqueeSelection;
    private adjustMarqueeSelectOutline;
    private hideMarqueeSelectOutline;
    private onPointerOut;
    private onKeyUp;
    private attachEvents;
    private attachWindowEvents;
    private detachEvents;
    private detachWindowEvents;
    private getMarkerTypeByName;
    /**
     * Switches the marker area to select mode and deselects all the selected markers.
     */
    switchToSelectMode(): void;
    /**
     * Returns the annotation state.
     * @returns
     */
    getState(): AnnotationState;
    private _stateToRestore;
    /**
     * Restores the annotation from the previously saved state.
     * @param state
     * @param addUndoStep if true (default) or omitted, an undo step is added after restoring the state
     */
    restoreState(state: AnnotationState, addUndoStep?: boolean): void;
    private scaleMarkers;
    /**
     * NOTE:
     *
     * before removing or modifying this method please consider supporting marker.js
     * by visiting https://markerjs.com/ for details
     *
     * thank you!
     */
    private toggleLogo;
    private addLogo;
    private removeLogo;
    private positionLogo;
    /**
     * Returns true if undo operation can be performed (undo stack is not empty).
     */
    get isUndoPossible(): boolean;
    /**
     * Returns true if redo operation can be performed (redo stack is not empty).
     */
    get isRedoPossible(): boolean;
    private addUndoStep;
    /**
     * Undo last action.
     */
    undo(): void;
    private undoStep;
    /**
     * Redo previously undone action.
     */
    redo(): void;
    private redoStep;
    /**
     * Adds "defs" to main canvas SVG.
     * Useful for filters, custom fonts and potentially other scenarios.
     *
     * @param nodes
     * @since 3.3.0
     */
    addDefs(...nodes: (string | Node)[]): void;
    addEventListener<T extends keyof MarkerAreaEventMap>(type: T, listener: (this: MarkerArea, ev: MarkerAreaEventMap[T]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener<K extends keyof HTMLElementEventMap>(type: K, listener: (this: HTMLElement, ev: HTMLElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions | undefined): void;
    removeEventListener<T extends keyof MarkerAreaEventMap>(type: T, listener: (this: MarkerArea, ev: MarkerAreaEventMap[T]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener<K extends keyof HTMLElementEventMap>(type: K, listener: (this: HTMLElement, ev: HTMLElementEventMap[K]) => void, options?: boolean | EventListenerOptions | undefined): void;
}

/**
 * Represents location of the manipulation grips.
 */
type GripLocation = 'topleft' | 'topcenter' | 'topright' | 'leftcenter' | 'rightcenter' | 'bottomleft' | 'bottomcenter' | 'bottomright';
/**
 * Represents a single resize-manipulation grip used in marker's manipulation controls.
 */
declare class Grip {
    /**
     * Grip's visual element.
     */
    protected _visual?: SVGGraphicsElement;
    /**
     * Grip's visual element.
     */
    get visual(): SVGGraphicsElement;
    /**
     * Grip's size (radius).
     */
    gripSize: number;
    /**
     * Grip's fill color.
     */
    fillColor: string;
    /**
     * Grip's stroke color.
     */
    strokeColor: string;
    /**
     * Creates a new grip.
     */
    constructor();
    /**
     * Creates grip's visual.
     */
    protected createVisual(): void;
    /**
     * Returns true if passed SVG element belongs to the grip. False otherwise.
     *
     * @param el - target element.
     */
    ownsTarget(el: EventTarget): boolean;
}

/**
 * Represents a resize grip.
 */
declare class ResizeGrip extends Grip {
}

/**
 * Represents a rotation grip.
 */
declare class RotateGrip extends Grip {
    constructor();
}

/**
 * Base editor for markers that can be represented by a rectangular area.
 *
 * @summary Base editor for markers that can be represented by a rectangular area.
 * @group Editors
 */
declare class RectangularBoxMarkerBaseEditor<TMarkerType extends RectangularBoxMarkerBase = RectangularBoxMarkerBase> extends MarkerBaseEditor<TMarkerType> {
    /**
     * x coordinate of the top-left corner at the start of manipulation.
     */
    protected manipulationStartLeft: number;
    /**
     * y coordinate of the top-left corner at the start of manipulation.
     */
    protected manipulationStartTop: number;
    /**
     * Width at the start of manipulation.
     */
    protected manipulationStartWidth: number;
    /**
     * Height at the start of manipulation.
     */
    protected manipulationStartHeight: number;
    /**
     * x coordinate of the pointer at the start of manipulation.
     */
    protected manipulationStartX: number;
    /**
     * y coordinate of the pointer at the start of manipulation.
     */
    protected manipulationStartY: number;
    /**
     * Pointer's horizontal distance from the top left corner.
     */
    protected offsetX: number;
    /**
     * Pointer's vertical distance from the top left corner.
     */
    protected offsetY: number;
    /**
     * Container for the marker's editing controls.
     */
    protected controlBox: SVGGElement;
    /**
     * Container for the marker's manipulation grips.
     */
    protected manipulationBox: SVGGElement;
    private readonly CB_DISTANCE;
    private controlRect?;
    private rotatorGripLine?;
    private controlGrips;
    /**
     * Array of disabled resize grips.
     *
     * Use this in derived classes to disable specific resize grips.
     */
    protected disabledResizeGrips: GripLocation[];
    private rotatorGrip?;
    /**
     * Active grip during manipulation
     */
    protected activeGrip?: Grip;
    private disableRotation;
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    ownsTarget(el: EventTarget): boolean;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    /**
     * When set to true marker created event will not be triggered.
     */
    protected _suppressMarkerCreateEvent: boolean;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
    manipulate(point: IPoint, ev?: PointerEvent): void;
    protected resize(point: IPoint, preserveAspectRatio?: boolean): void;
    /**
     * Sets control box size and location.
     */
    protected setSize(): void;
    select(multi?: boolean): void;
    deselect(): void;
    /**
     * Creates control box for manipulation controls.
     */
    protected setupControlBox(): void;
    /**
     * Adjusts control box size and location.
     */
    protected adjustControlBox(): void;
    /**
     * Adds control grips to control box.
     */
    protected addControlGrips(): void;
    private createRotateGrip;
    /**
     * Updates manipulation grip layout.
     */
    protected positionGrips(): void;
    /**
     * Positions specific grip.
     * @param grip
     * @param x
     * @param y
     */
    protected positionGrip(grip: SVGGraphicsElement | undefined, x: number, y: number): void;
    /**
     * Hides marker's editing controls.
     */
    protected hideControlBox(): void;
    /**
     * Shows marker's editing controls.
     */
    protected showControlBox(): void;
    /**
     * Adjusts visibility of resize grips.
     */
    protected adjustGripVisibility(): void;
    scale(scaleX: number, scaleY: number): void;
}

/**
 * Editor for shape outline markers.
 *
 * @summary Shape outline (unfilled shape) marker editor.
 * @group Editors
 */
declare class ShapeOutlineMarkerEditor<TMarkerType extends ShapeOutlineMarkerBase = ShapeOutlineMarkerBase> extends RectangularBoxMarkerBaseEditor<TMarkerType> {
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    protected resize(point: IPoint, preserveAspectRatio?: boolean): void;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
}

/**
 * Editor for filled shape markers.
 *
 * @summary Filled shape marker editor.
 * @group Editors
 */
declare class ShapeMarkerEditor<TMarkerType extends ShapeMarkerBase = ShapeMarkerBase> extends ShapeOutlineMarkerEditor<TMarkerType> {
}

/**
 * Editor for linear markers.
 *
 * @summary Editor for line-like markers.
 * @group Editors
 */
declare class LinearMarkerEditor<TMarkerType extends LinearMarkerBase = LinearMarkerBase> extends MarkerBaseEditor<TMarkerType> {
    /**
     * Default line length when marker is created with a simple click (without dragging).
     */
    protected defaultLength: number;
    /**
     * Pointer X coordinate at the start of move or resize.
     */
    protected manipulationStartX: number;
    /**
     * Pointer Y coordinate at the start of move or resize.
     */
    protected manipulationStartY: number;
    private manipulationStartX1;
    private manipulationStartY1;
    private manipulationStartX2;
    private manipulationStartY2;
    /**
     * Container for manipulation grips.
     */
    protected manipulationBox: SVGGElement;
    /**
     * First manipulation grip
     */
    protected grip1?: ResizeGrip;
    /**
     * Second manipulation grip.
     */
    protected grip2?: ResizeGrip;
    /**
     * Active manipulation grip.
     */
    protected activeGrip?: ResizeGrip;
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    ownsTarget(el: EventTarget): boolean;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
    manipulate(point: IPoint, ev?: PointerEvent): void;
    protected resize(point: IPoint): void;
    /**
     * Creates control box for manipulation controls.
     */
    protected setupControlBox(): void;
    protected adjustControlBox(): void;
    /**
     * Adds control grips to control box.
     */
    protected addControlGrips(): void;
    /**
     * Creates manipulation grip.
     * @returns - manipulation grip.
     */
    protected createGrip(): ResizeGrip;
    /**
     * Updates manipulation grip layout.
     */
    protected positionGrips(): void;
    /**
     * Positions manipulation grip.
     * @param grip - grip to position
     * @param x - new X coordinate
     * @param y - new Y coordinate
     */
    protected positionGrip(grip: SVGGraphicsElement, x: number, y: number): void;
    select(multi?: boolean): void;
    deselect(): void;
}

/**
 * Editor for polygon markers.
 *
 * @summary Polygon marker editor.
 * @group Editors
 */
declare class PolygonMarkerEditor<TMarkerType extends PolygonMarker = PolygonMarker> extends MarkerBaseEditor<TMarkerType> {
    /**
     * Default line length when marker is created with a simple click (without dragging).
     */
    protected defaultLength: number;
    /**
     * Pointer X coordinate at the start of move or resize.
     */
    protected manipulationStartX: number;
    /**
     * Pointer Y coordinate at the start of move or resize.
     */
    protected manipulationStartY: number;
    /**
     * Container for control elements.
     */
    protected controlBox: SVGGElement;
    /**
     * Container for manipulation grips.
     */
    protected manipulationBox: SVGGElement;
    /**
     * Array of manipulation grips.
     */
    protected grips: ResizeGrip[];
    /**
     * Active manipulation grip.
     */
    protected activeGrip?: ResizeGrip;
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    ownsTarget(el: EventTarget): boolean;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    private startCreation;
    private addNewPointWhileCreating;
    private finishCreation;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
    manipulate(point: IPoint, ev?: PointerEvent): void;
    protected resize(point: IPoint): void;
    dblClick(point: IPoint, target?: EventTarget, ev?: MouseEvent): void;
    /**
     * Creates control box for manipulation controls.
     */
    protected setupControlBox(): void;
    protected adjustControlBox(): void;
    /**
     * Adds control grips to control box.
     */
    protected adjustControlGrips(): void;
    /**
     * Creates manipulation grip.
     * @returns - manipulation grip.
     */
    protected createGrip(): ResizeGrip;
    /**
     * Updates manipulation grip layout.
     */
    protected positionGrips(): void;
    /**
     * Positions manipulation grip.
     * @param grip - grip to position
     * @param x - new X coordinate
     * @param y - new Y coordinate
     */
    protected positionGrip(grip: SVGGraphicsElement, x: number, y: number): void;
    select(multi?: boolean): void;
    deselect(): void;
}

/**
 * Editor for freehand markers.
 *
 * @summary Freehand marker editor.
 * @group Editors
 */
declare class FreehandMarkerEditor<TMarkerType extends FreehandMarker = FreehandMarker> extends MarkerBaseEditor<TMarkerType> {
    /**
     * Pointer X coordinate at the start of move or resize.
     */
    protected manipulationStartX: number;
    /**
     * Pointer Y coordinate at the start of move or resize.
     */
    protected manipulationStartY: number;
    /**
     * Container for control elements.
     */
    protected controlBox: SVGGElement;
    private controlRect?;
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    ownsTarget(el: EventTarget): boolean;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    private startCreation;
    private addNewPointWhileCreating;
    private finishCreation;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
    manipulate(point: IPoint, ev?: PointerEvent): void;
    /**
     * Creates control box for manipulation controls.
     */
    protected setupControlBox(): void;
    protected adjustControlBox(): void;
    select(): void;
    deselect(): void;
}

/**
 * Text changed event handler type.
 */
type TextChangedHandler = (text: string) => void;
/**
 * Blur event handler type.
 */
type BlurHandler = () => void;
/**
 * Represents a text block editor element.
 */
declare class TextBlockEditor {
    private textEditor;
    private isInFocus;
    private _width;
    /**
     * Returns editor width in pixels.
     */
    get width(): number;
    /**
     * Sets editor width in pixels.
     */
    set width(value: number);
    private _height;
    /**
     * Returns editor height in pixels.
     */
    get height(): number;
    /**
     * Sets editor height in pixels.
     */
    set height(value: number);
    private _left;
    /**
     * Returns the horizontal (X) location of the editor's left corner (in pixels).
     */
    get left(): number;
    /**
     * Sets the horizontal (X) location of the editor's left corner (in pixels).
     */
    set left(value: number);
    private _top;
    /**
     * Returns the vertical (Y) location of the editor's top left corner (in pixels).
     */
    get top(): number;
    /**
     * Sets the vertical (Y) location of the editor's top left corner (in pixels).
     */
    set top(value: number);
    private _text;
    /**
     * Returns the text block text.
     */
    get text(): string;
    /**
     * Sets the text block text.
     */
    set text(value: string);
    private _fontFamily;
    /**
     * Returns text block's font family.
     */
    get fontFamily(): string;
    /**
     * Sets the text block's font family.
     */
    set fontFamily(value: string);
    private _fontSize;
    /**
     * Returns text block's font size.
     */
    get fontSize(): string;
    /**
     * Sets text block's font size.
     */
    set fontSize(value: string);
    private _textColor;
    /**
     * Returns text block's font color.
     */
    get textColor(): string;
    /**
     * Returns text block's font color.
     */
    set textColor(value: string);
    private _bgColor;
    /**
     * Returns text block's background color.
     */
    get bgColor(): string;
    /**
     * Sets text block's background color.
     */
    set bgColor(value: string);
    /**
     * Text changed event handler.
     */
    onTextChanged?: TextChangedHandler;
    /**
     * Blur event handler.
     */
    onBlur?: BlurHandler;
    /**
     * Creates a new text block editor instance.
     */
    constructor();
    private isSetupCompleted;
    private setup;
    /**
     * Returns editor's UI,
     * @returns UI in a div element.
     */
    getEditorUi(): HTMLDivElement;
    /**
     * Focuses text editing in the editor.
     */
    focus(): void;
    /**
     * Unfocuses the editor.
     */
    blur(): void;
}

/**
 * Editor for text markers.
 *
 * @summary Text marker editor.
 * @group Editors
 */
declare class TextMarkerEditor<TMarkerType extends TextMarker = TextMarker> extends RectangularBoxMarkerBaseEditor<TMarkerType> {
    /**
     * Container for text block editor.
     */
    protected textBlockEditorContainer: SVGForeignObjectElement;
    /**
     * Text block editor.
     */
    protected textBlockEditor: TextBlockEditor;
    /**
     * Text color.
     */
    set color(color: string);
    /**
     * Text color.
     */
    get color(): string;
    /**
     * Sets text's font family.
     */
    set fontFamily(font: string);
    /**
     * Returns text's font family.
     */
    get fontFamily(): string;
    /**
     * Sets text's font size.
     */
    set fontSize(size: FontSize);
    /**
     * Returns text's font size.
     */
    get fontSize(): FontSize;
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    private _pointerDownTime;
    private _pointerDownPoint;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    dblClick(point: IPoint, target?: EventTarget, ev?: MouseEvent): void;
    protected setSize(): void;
    protected resize(point: IPoint, preserveAspectRatio?: boolean): void;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
    private showEditor;
    private hideEditor;
    private markerSizeChanged;
}

/**
 * Editor for arrow markers.
 *
 * @summary Arrow marker editor.
 * @group Editors
 */
declare class ArrowMarkerEditor<TMarkerType extends ArrowMarker = ArrowMarker> extends LinearMarkerEditor<TMarkerType> {
    /**
     * Sets the arrow type.
     */
    set arrowType(value: ArrowType);
    /**
     * Returns the arrow type.
     */
    get arrowType(): ArrowType;
}

/**
 * Editor for callout markers.
 *
 * @summary Callout marker editor.
 * @group Editors
 */
declare class CalloutMarkerEditor<TMarkerType extends CalloutMarker = CalloutMarker> extends TextMarkerEditor<TMarkerType> {
    private tipGrip?;
    private manipulationStartTipPositionX;
    private manipulationStartTipPositionY;
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    protected addControlGrips(): void;
    private createTipGrip;
    protected positionGrips(): void;
    ownsTarget(el: EventTarget): boolean;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    protected resize(point: IPoint, preserveAspectRatio?: boolean): void;
}

/**
 * Editor for image markers.
 *
 * @summary Image marker editor.
 * @group Editors
 */
declare class ImageMarkerEditor<TMarkerType extends ImageMarkerBase = ImageMarkerBase> extends RectangularBoxMarkerBaseEditor<TMarkerType> {
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    pointerUp(point: IPoint, ev?: PointerEvent): void;
}

/**
 * Editor for caption frame markers.
 *
 * @summary Caption frame marker editor.
 * @group Editors
 */
declare class CaptionFrameMarkerEditor<TMarkerType extends CaptionFrameMarker = CaptionFrameMarker> extends TextMarkerEditor<TMarkerType> {
    constructor(properties: MarkerEditorProperties<TMarkerType>);
    protected setSize(): void;
}

declare class CurveMarkerEditor<TMarkerType extends CurveMarker = CurveMarker> extends LinearMarkerEditor<TMarkerType> {
    /**
     * Curve manipulation grip.
     */
    protected curveGrip?: ResizeGrip;
    private manipulationStartCurveX;
    private manipulationStartCurveY;
    private curveControlLine1?;
    private curveControlLine2?;
    ownsTarget(el: EventTarget): boolean;
    pointerDown(point: IPoint, target?: EventTarget, ev?: PointerEvent): void;
    protected resize(point: IPoint): void;
    manipulate(point: IPoint, ev?: PointerEvent): void;
    protected setupControlBox(): void;
    protected adjustControlBox(): void;
    protected addControlGrips(): void;
    protected positionGrips(): void;
}

/**
 * Event map for {@link MarkerView}.
 */
interface MarkerViewEventMap {
    /**
     * Viewer initialized.
     */
    viewinit: CustomEvent<MarkerViewEventData>;
    /**
     * Viewer shown.
     */
    viewshow: CustomEvent<MarkerViewEventData>;
    /**
     * Viewer state restored.
     */
    viewrestorestate: CustomEvent<MarkerViewEventData>;
    /**
     * Marker clicked.
     */
    markerclick: CustomEvent<MarkerEventData>;
    /**
     * Marker mouse over.
     */
    markerover: CustomEvent<MarkerEventData>;
    /**
     * Marker pointer down.
     */
    markerpointerdown: CustomEvent<MarkerEventData>;
    /**
     * Marker pointer move.
     */
    markerpointermove: CustomEvent<MarkerEventData>;
    /**
     * Marker pointer up.
     */
    markerpointerup: CustomEvent<MarkerEventData>;
    /**
     * Marker pointer enter.
     */
    markerpointerenter: CustomEvent<MarkerEventData>;
    /**
     * Marker pointer leave.
     */
    markerpointerleave: CustomEvent<MarkerEventData>;
}
/**
 * Event data for {@link MarkerView}.
 */
interface MarkerViewEventData {
    /**
     * {@link MarkerView} instance.
     */
    markerView: MarkerView;
}
/**
 * Marker custom event data.
 */
interface MarkerEventData extends MarkerViewEventData {
    /**
     * Marker instance.
     */
    marker: MarkerBase;
}
/**
 * MarkerView is the main annotation viewer web component.
 *
 * @summary
 * The main annotation viewer web component.
 *
 * @group Components
 *
 * @example
 * To show dynamic annotation overlays on top of the original image you use `MarkerView`.
 * ```js
 * import { MarkerView } from '@markerjs/markerjs3';
 *
 * const markerView = new MarkerView();
 * markerView.targetImage = targetImg;
 * viewerContainer.appendChild(markerView);
 *
 * markerView.show(savedState);
 * ```
 */
declare class MarkerView extends HTMLElement {
    private _contentContainer?;
    private _canvasContainer?;
    private _mainCanvas?;
    private _groupLayer?;
    private _editingTarget?;
    private width;
    private height;
    private _targetWidth;
    /**
     * Returns the target image width.
     */
    get targetWidth(): number;
    /**
     * Sets the target image width.
     */
    set targetWidth(value: number);
    private _targetHeight;
    /**
     * Returns the target image height.
     */
    get targetHeight(): number;
    /**
     * Sets the target image height.
     */
    set targetHeight(value: number);
    private _targetImageLoaded;
    private _targetImage;
    /**
     * Returns the target image.
     */
    get targetImage(): HTMLImageElement | undefined;
    /**
     * Sets the target image.
     */
    set targetImage(value: HTMLImageElement | undefined);
    /**
     * Marker types available for the viewer.
     */
    markerTypes: Array<typeof MarkerBase>;
    /**
     * Collection of markers currently displayed on the viewer.
     */
    markers: MarkerBase[];
    private _logoUI?;
    private _zoomLevel;
    /**
     * Returns the current zoom level.
     */
    get zoomLevel(): number;
    /**
     * Sets the current zoom level.
     */
    set zoomLevel(value: number);
    private _defaultFilter?;
    /**
     * Returns the default SVG filter for the created markers.
     *
     * @since 3.2.0
     */
    get defaultFilter(): string | undefined;
    /**
     * Sets the default SVG filter for the created markers
     * (e.g. "drop-shadow(2px 2px 2px black)").
     *
     * @since 3.2.0
     */
    set defaultFilter(value: string | undefined);
    private _isInitialized;
    private _defsElement?;
    private _defs;
    private prevPanPoint;
    constructor();
    private connectedCallback;
    private disconnectedCallback;
    private createLayout;
    private addMainCanvas;
    private addDefsToMainCanvas;
    private setMainCanvasSize;
    private setEditingTargetSize;
    private addTargetImage;
    private addDefaultFilterDefs;
    private addNewMarker;
    private attachMarkerEvents;
    private attachEvents;
    private attachWindowEvents;
    private detachEvents;
    private detachWindowEvents;
    private touchPoints;
    private leadPointerId?;
    private onCanvasPointerDown;
    private onPointerMove;
    private onPointerUp;
    private onPointerOut;
    private getMarkerTypeByName;
    /**
     * Adds a new marker type to be available in the viewer.
     * @param markerType
     */
    registerMarkerType(markerType: typeof MarkerBase): void;
    private _stateToRestore;
    /**
     * Loads and shows previously saved annotation state.
     * @param state
     */
    show(state: AnnotationState): void;
    private scaleMarkers;
    private panTo;
    /**
     * NOTE:
     *
     * before removing or modifying this method please consider supporting marker.js
     * by visiting https://markerjs.com/buy for details
     *
     * thank you!
     */
    private toggleLogo;
    private addLogo;
    private removeLogo;
    private positionLogo;
    /**
     * Adds "defs" to main canvas SVG.
     * Useful for filters, custom fonts and potentially other scenarios.
     * @since 3.3.0
     */
    addDefs(...nodes: (string | Node)[]): void;
    addEventListener<T extends keyof MarkerViewEventMap>(type: T, listener: (this: MarkerView, ev: MarkerViewEventMap[T]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener<K extends keyof HTMLElementEventMap>(type: K, listener: (this: HTMLElement, ev: HTMLElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions | undefined): void;
    removeEventListener<T extends keyof MarkerViewEventMap>(type: T, listener: (this: MarkerView, ev: MarkerViewEventMap[T]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener<K extends keyof HTMLElementEventMap>(type: K, listener: (this: HTMLElement, ev: HTMLElementEventMap[K]) => void, options?: boolean | EventListenerOptions | undefined): void;
}

/**
 * @module Renderer
 * @category API Reference
 */

/**
 * Renderer is used to rasterize annotations.
 *
 * @example
 * To render the annotation as a static image you use `Renderer`.
 *
 * ```js
 * import { MarkerArea, Renderer } from '@markerjs/markerjs3';
 * ```
 *
 * Just create an instance of it and pass the annotation state to the `rasterize()` method:
 *
 * ```js
 * const renderer = new Renderer();
 * renderer.targetImage = targetImg;
 * const dataUrl = await renderer.rasterize(markerArea.getState());
 *
 * const img = document.createElement('img');
 * img.src = dataUrl;
 *
 * someDiv.appendChild(img);
 * ```
 */
declare class Renderer {
    private _mainCanvas?;
    private _editingTarget?;
    private _renderHelperContainer?;
    private _targetWidth;
    /**
     * Width of the target image.
     */
    get targetWidth(): number;
    /**
     * Width of the target image.
     */
    set targetWidth(value: number);
    private _targetHeight;
    /**
     * Height of the target image.
     */
    get targetHeight(): number;
    /**
     * Height of the target image.
     */
    set targetHeight(value: number);
    private _targetImageLoaded;
    private _targetImage;
    /**
     * Target image to render annotations on.
     */
    get targetImage(): HTMLImageElement | undefined;
    /**
     * Target image to render annotations on.
     */
    set targetImage(value: HTMLImageElement | undefined);
    /**
     * Marker types available for rendering.
     */
    markerTypes: Array<typeof MarkerBase>;
    /**
     * Array of markers to render.
     */
    markers: MarkerBase[];
    private _isInitialized;
    /**
     * Whether the image should be rendered at the original (natural) target image size.
     */
    naturalSize: boolean;
    /**
     * Rendered image type (`image/png`, `image/jpeg`, etc.).
     */
    imageType: string;
    /**
     * For formats that support it, specifies rendering quality.
     *
     * In the case of `image/jpeg` you can specify a value between 0 and 1 (lowest to highest quality).
     *
     * @type {number} - image rendering quality (0..1)
     */
    imageQuality?: number;
    /**
     * When set to true, only the marker layer without the original image will be rendered.
     */
    markersOnly: boolean;
    /**
     * When set and {@linkcode naturalSize} is `false` sets the width of the rendered image.
     *
     * Both `width` and `height` have to be set for this to take effect.
     */
    width?: number;
    /**
     * When set and {@linkcode naturalSize} is `false` sets the height of the rendered image.
     *
     * Both `width` and `height` have to be set for this to take effect.
     */
    height?: number;
    private _defaultFilter?;
    /**
     * Returns the default SVG filter for the created markers.
     *
     * @since 3.2.0
     */
    get defaultFilter(): string | undefined;
    /**
     * Sets the default SVG filter for the created markers
     * (e.g. "drop-shadow(2px 2px 2px black)").
     *
     * @since 3.2.0
     */
    set defaultFilter(value: string | undefined);
    private _defsElement?;
    private _defs;
    constructor();
    private init;
    private addMainCanvas;
    private addDefsToMainCanvas;
    private setMainCanvasSize;
    private setEditingTargetSize;
    private addTargetImage;
    private addDefaultFilterDefs;
    private addNewMarker;
    private getMarkerTypeByName;
    /**
     * Adds a new marker type to the list of available marker types.
     * @param markerType - Marker type to register.
     */
    registerMarkerType(markerType: typeof MarkerBase): void;
    /**
     * Restores the annotation state.
     * @param state - Annotation state to restore.
     */
    restoreState(state: AnnotationState): void;
    private scaleMarkers;
    /**
     * Rasterizes the annotation.
     * @param state - annotation state to render.
     * @param targetCanvas - optional target canvas to render the annotation on.
     * @returns
     */
    rasterize(state: AnnotationState, targetCanvas?: HTMLCanvasElement): Promise<string>;
    /**
     * Adds "defs" to main canvas SVG.
     * Useful for filters, custom fonts and potentially other scenarios.
     * @since 3.3.0
     */
    addDefs(...nodes: (string | Node)[]): void;
}

export { Activator, type AnnotationState, ArrowMarker, ArrowMarkerEditor, type ArrowMarkerState, type ArrowType, type BlurHandler, CalloutMarker, CalloutMarkerEditor, type CalloutMarkerState, CaptionFrameMarker, CaptionFrameMarkerEditor, type CaptionFrameMarkerState, CheckImageMarker, CoverMarker, CurveMarker, CurveMarkerEditor, type CurveMarkerState, CustomImageMarker, EllipseFrameMarker, EllipseMarker, type FontSize, FrameMarker, FreehandMarker, FreehandMarkerEditor, type FreehandMarkerState, Grip, type GripLocation, HighlightMarker, HighlighterMarker, type IPoint, type ISize, type ITransformMatrix, ImageMarkerBase, type ImageMarkerBaseState, ImageMarkerEditor, type ImageType, LineMarker, LinearMarkerBase, type LinearMarkerBaseState, LinearMarkerEditor, MarkerArea, type MarkerAreaEventData, type MarkerAreaEventMap, type MarkerAreaMode, MarkerBase, MarkerBaseEditor, type MarkerBaseState, type MarkerCreationStyle, type MarkerEditorEventData, type MarkerEditorProperties, type MarkerEditorState, type MarkerEventData, type MarkerStage, MarkerView, type MarkerViewEventData, type MarkerViewEventMap, MeasurementMarker, PolygonMarker, PolygonMarkerEditor, type PolygonMarkerState, RectangularBoxMarkerBase, type RectangularBoxMarkerBaseState, Renderer, ResizeGrip, RotateGrip, ShapeMarkerBase, type ShapeMarkerBaseState, ShapeMarkerEditor, ShapeOutlineMarkerBase, type ShapeOutlineMarkerBaseState, ShapeOutlineMarkerEditor, SvgFilters, SvgHelper, TextBlock, TextBlockEditor, type TextChangedHandler, TextMarker, TextMarkerEditor, type TextMarkerState, XImageMarker };
