import streamlit as st
import serial
from PIL import Image, ImageOps
import time


# ============================================================
# HARDWARE CONFIGURATION
# ============================================================
COM_PORT = "COM5"
BAUD_RATE = 115200


# ============================================================
# PAGE CONFIGURATION
# ============================================================
st.set_page_config(
    page_title="ESP32-S3 Hardware AI",
    page_icon="🧠",
    layout="wide",
    initial_sidebar_state="expanded",
)


# ============================================================
# CUSTOM UI STYLE
# ============================================================
st.markdown(
    """
    <style>
    .stApp {
        background: #0b1220;
    }

    .block-container {
        max-width: 1250px;
        padding-top: 2rem;
        padding-bottom: 3rem;
    }

    .hero {
        padding: 28px 32px;
        border: 1px solid #26344d;
        border-radius: 18px;
        background: linear-gradient(135deg, #111c31 0%, #0d1627 100%);
        margin-bottom: 22px;
    }

    .hero-title {
        font-size: 2.35rem;
        font-weight: 750;
        color: #f8fafc;
        margin-bottom: 5px;
    }

    .hero-subtitle {
        font-size: 1.02rem;
        color: #9fb0c8;
        margin-bottom: 16px;
    }

    .badge {
        display: inline-block;
        padding: 6px 12px;
        margin-right: 7px;
        border-radius: 999px;
        border: 1px solid #31425e;
        color: #cbd8eb;
        background: #152238;
        font-size: 0.82rem;
    }

    .section-title {
        color: #f1f5f9;
        font-size: 1.35rem;
        font-weight: 700;
        margin-top: 22px;
        margin-bottom: 12px;
    }

    .section-caption {
        color: #91a2ba;
        margin-bottom: 16px;
    }

    .workflow {
        display: flex;
        align-items: stretch;
        gap: 8px;
        margin: 10px 0 24px 0;
    }

    .workflow-step {
        flex: 1;
        min-height: 125px;
        padding: 16px 12px;
        border: 1px solid #2a3a55;
        border-radius: 14px;
        background: #111b2d;
        text-align: center;
    }

    .workflow-number {
        font-size: 0.75rem;
        color: #7f93b0;
        font-weight: 700;
        letter-spacing: 0.08em;
    }

    .workflow-icon {
        font-size: 1.55rem;
        margin: 5px 0;
    }

    .workflow-name {
        color: #e8eef8;
        font-weight: 700;
        font-size: 0.92rem;
    }

    .workflow-detail {
        color: #879ab6;
        font-size: 0.76rem;
        margin-top: 5px;
    }

    .arrow {
        display: flex;
        align-items: center;
        color: #526783;
        font-size: 1.25rem;
    }

    .pipeline-box {
        border: 1px solid #2a3a55;
        border-radius: 16px;
        padding: 18px;
        background: #101a2b;
        margin-top: 8px;
    }

    .pipeline-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 7px;
        flex-wrap: wrap;
    }

    .pipeline-node {
        padding: 9px 14px;
        border-radius: 9px;
        background: #18263d;
        border: 1px solid #30435f;
        color: #dbe7f7;
        font-size: 0.85rem;
        font-weight: 600;
    }

    .pipeline-arrow {
        color: #7186a3;
    }

    .stage-box {
        border: 1px solid #293b58;
        border-radius: 12px;
        background: #111c2e;
        padding: 12px 14px;
        margin-bottom: 8px;
    }

    .stage-done {
        color: #8fe3b1;
    }

    .stage-current {
        color: #f6c86b;
    }

    .stage-pending {
        color: #7f91aa;
    }

    .result-box {
        text-align: center;
        padding: 25px;
        border-radius: 18px;
        border: 1px solid #35516f;
        background: linear-gradient(135deg, #12253a 0%, #0e1a2b 100%);
        margin: 15px 0;
    }

    .result-label {
        color: #9fb0c8;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.12em;
    }

    .result-digit {
        color: #ffffff;
        font-size: 5rem;
        line-height: 1;
        font-weight: 800;
        margin: 12px 0;
    }

    .metric-card {
        border: 1px solid #293b58;
        border-radius: 13px;
        background: #111c2e;
        padding: 14px 16px;
        min-height: 88px;
    }

    .metric-label {
        color: #8194af;
        font-size: 0.76rem;
        text-transform: uppercase;
        letter-spacing: 0.08em;
    }

    .metric-value {
        color: #eaf1fb;
        font-size: 1.2rem;
        font-weight: 700;
        margin-top: 6px;
    }

    .architecture {
        border: 1px solid #2a3a55;
        border-radius: 16px;
        background: #101a2b;
        padding: 20px;
        text-align: center;
    }

    .layer {
        display: inline-block;
        padding: 12px 16px;
        margin: 4px;
        border-radius: 10px;
        background: #172740;
        border: 1px solid #304766;
        color: #dce8f7;
        font-weight: 700;
    }

    .layer small {
        display: block;
        color: #8194af;
        font-weight: 400;
        margin-top: 4px;
    }

    .info-card {
        border: 1px solid #293b58;
        border-radius: 14px;
        background: #111c2e;
        padding: 17px;
        min-height: 135px;
    }

    .info-title {
        color: #e8eef8;
        font-weight: 700;
        margin-bottom: 7px;
    }

    .info-text {
        color: #8fa1bb;
        font-size: 0.88rem;
        line-height: 1.5;
    }

    .footer {
        text-align: center;
        color: #647793;
        border-top: 1px solid #202f46;
        padding-top: 18px;
        margin-top: 35px;
        font-size: 0.78rem;
    }

    [data-testid="stFileUploader"] {
        border: 1px solid #2a3a55;
        border-radius: 14px;
        padding: 8px;
        background: #101a2b;
    }

    div.stButton > button {
        width: 100%;
        min-height: 48px;
        border-radius: 10px;
        font-weight: 700;
    }
    </style>
    """,
    unsafe_allow_html=True,
)


# ============================================================
# HEADER
# ============================================================
st.markdown(
    """
    <div class="hero">
        <div class="hero-title">🧠 ESP32-S3 Hardware AI</div>
        <div class="hero-subtitle">
            Handwritten Digit Recognition using an integer neural network
            deployed directly on edge hardware.
        </div>
        <span class="badge">ESP32-S3</span>
        <span class="badge">Hardware Inference</span>
        <span class="badge">784 → 32 → 16 → 10</span>
        <span class="badge">USB Serial</span>
    </div>
    """,
    unsafe_allow_html=True,
)


# ============================================================
# SYSTEM WORKFLOW
# ============================================================
st.markdown('<div class="section-title">How the System Works</div>', unsafe_allow_html=True)
st.markdown(
    '<div class="section-caption">The uploaded image moves through preprocessing, serial transfer, '
    'hardware inference, and prediction.</div>',
    unsafe_allow_html=True,
)

st.markdown(
    """
    <div class="workflow">
        <div class="workflow-step">
            <div class="workflow-number">01</div>
            <div class="workflow-icon">🖼️</div>
            <div class="workflow-name">Upload</div>
            <div class="workflow-detail">Handwritten digit image</div>
        </div>
        <div class="arrow">→</div>
        <div class="workflow-step">
            <div class="workflow-number">02</div>
            <div class="workflow-icon">⚙️</div>
            <div class="workflow-name">Preprocess</div>
            <div class="workflow-detail">Grayscale + 28×28</div>
        </div>
        <div class="arrow">→</div>
        <div class="workflow-step">
            <div class="workflow-number">03</div>
            <div class="workflow-icon">📡</div>
            <div class="workflow-name">Transmit</div>
            <div class="workflow-detail">784 bytes over USB serial</div>
        </div>
        <div class="arrow">→</div>
        <div class="workflow-step">
            <div class="workflow-number">04</div>
            <div class="workflow-icon">🧠</div>
            <div class="workflow-name">ESP32-S3 AI</div>
            <div class="workflow-detail">Integer MLP inference</div>
        </div>
        <div class="arrow">→</div>
        <div class="workflow-step">
            <div class="workflow-number">05</div>
            <div class="workflow-icon">🎯</div>
            <div class="workflow-name">Prediction</div>
            <div class="workflow-detail">Digit 0–9</div>
        </div>
    </div>
    """,
    unsafe_allow_html=True,
)


# ============================================================
# MAIN TEST AREA
# ============================================================
st.markdown('<div class="section-title">Live Hardware Test</div>', unsafe_allow_html=True)

left, right = st.columns([1, 1], gap="large")

with left:
    st.markdown("#### 1. Upload Input")
    uploaded_file = st.file_uploader(
        "Choose a handwritten digit image",
        type=["png", "jpg", "jpeg"],
        help="Upload a handwritten digit from 0 to 9.",
    )

with right:
    st.markdown("#### 2. Hardware Connection")
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-label">Target Device</div>
            <div class="metric-value">Heltec ESP32-S3</div>
        </div>
        <br>
        <div class="metric-card">
            <div class="metric-label">Serial Interface</div>
            <div class="metric-value">{COM_PORT} @ {BAUD_RATE} baud</div>
        </div>
        """,
        unsafe_allow_html=True,
    )


if uploaded_file is not None:

    # ========================================================
    # IMAGE PREPROCESSING
    # ========================================================
    original_img = Image.open(uploaded_file).convert("L")

    # Preserve the existing preprocessing pipeline exactly.
    processed_img = original_img.resize((28, 28))
    processed_img = ImageOps.invert(processed_img)

    pixel_data = list(processed_img.getdata())
    raw_bytes = bytearray(pixel_data)

    st.markdown("---")
    st.markdown('<div class="section-title">Image Preprocessing</div>', unsafe_allow_html=True)
    st.markdown(
        '<div class="section-caption">The dashboard converts the uploaded image into the '
        '784-pixel input expected by the hardware model.</div>',
        unsafe_allow_html=True,
    )

    img_col1, img_col2, img_col3 = st.columns([1, 1, 1], gap="large")

    with img_col1:
        st.markdown("#### Original")
        st.image(original_img, use_container_width=True)

    with img_col2:
        st.markdown("#### Hardware Input")
        st.image(processed_img.resize((280, 280)), use_container_width=True)

    with img_col3:
        st.markdown(
            """
            <div class="info-card">
                <div class="info-title">Input Transformation</div>
                <div class="info-text">
                    1. Convert to grayscale<br>
                    2. Resize to 28 × 28 pixels<br>
                    3. Invert intensity<br>
                    4. Convert to 784 raw pixel values<br>
                    5. Send directly to the ESP32-S3
                </div>
            </div>
            <br>
            <div class="metric-card">
                <div class="metric-label">Payload</div>
                <div class="metric-value">784 bytes</div>
            </div>
            """,
            unsafe_allow_html=True,
        )

    # ========================================================
    # NEURAL NETWORK ARCHITECTURE
    # ========================================================
    st.markdown('<div class="section-title">Neural Network Running on Hardware</div>', unsafe_allow_html=True)

    st.markdown(
        """
        <div class="architecture">
            <div class="layer">INPUT<small>784 pixels</small></div>
            <span class="pipeline-arrow">→</span>
            <div class="layer">LAYER 1<small>784 → 32</small></div>
            <span class="pipeline-arrow">→</span>
            <div class="layer">LAYER 2<small>32 → 16</small></div>
            <span class="pipeline-arrow">→</span>
            <div class="layer">OUTPUT<small>16 → 10</small></div>
            <span class="pipeline-arrow">→</span>
            <div class="layer">ARGMAX<small>0–9</small></div>
        </div>
        """,
        unsafe_allow_html=True,
    )

    st.markdown("")

    # ========================================================
    # RUN HARDWARE INFERENCE
    # ========================================================
    if st.button("⚡ Run Inference on ESP32-S3", type="primary"):

        status_placeholder = st.empty()

        status_placeholder.markdown(
            """
            <div class="stage-box">
                <span class="stage-current">● Preparing image data...</span>
            </div>
            """,
            unsafe_allow_html=True,
        )

        try:
            with serial.Serial(COM_PORT, BAUD_RATE, timeout=2) as ser:

                status_placeholder.markdown(
                    """
                    <div class="stage-box">
                        <span class="stage-done">✓ Image preprocessed</span><br>
                        <span class="stage-current">● Sending 784-byte input to ESP32-S3...</span>
                    </div>
                    """,
                    unsafe_allow_html=True,
                )

                start_time = time.time()

                # Existing working communication protocol.
                ser.write(raw_bytes)

                status_placeholder.markdown(
                    """
                    <div class="stage-box">
                        <span class="stage-done">✓ Image preprocessed</span><br>
                        <span class="stage-done">✓ 784 bytes transmitted</span><br>
                        <span class="stage-current">● Waiting for hardware inference...</span>
                    </div>
                    """,
                    unsafe_allow_html=True,
                )

                result = ser.read(1)

                latency = (time.time() - start_time) * 1000

                if result:
                    prediction = result.decode("utf-8")

                    status_placeholder.markdown(
                        f"""
                        <div class="stage-box">
                            <span class="stage-done">✓ Image preprocessed</span><br>
                            <span class="stage-done">✓ 784 bytes transmitted</span><br>
                            <span class="stage-done">✓ ESP32-S3 inference completed</span><br>
                            <span class="stage-done">✓ Prediction received</span>
                        </div>
                        """,
                        unsafe_allow_html=True,
                    )

                    st.markdown(
                        f"""
                        <div class="result-box">
                            <div class="result-label">Hardware Prediction</div>
                            <div class="result-digit">{prediction}</div>
                            <div style="color:#9fb0c8;">
                                Predicted directly by the ESP32-S3 integer neural network
                            </div>
                        </div>
                        """,
                        unsafe_allow_html=True,
                    )

                    m1, m2, m3, m4 = st.columns(4)

                    with m1:
                        st.markdown(
                            """
                            <div class="metric-card">
                                <div class="metric-label">Prediction</div>
                                <div class="metric-value">Digit """ + prediction + """</div>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )

                    with m2:
                        st.markdown(
                            f"""
                            <div class="metric-card">
                                <div class="metric-label">End-to-End Latency</div>
                                <div class="metric-value">{latency:.2f} ms</div>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )

                    with m3:
                        st.markdown(
                            """
                            <div class="metric-card">
                                <div class="metric-label">Input</div>
                                <div class="metric-value">784 bytes</div>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )

                    with m4:
                        st.markdown(
                            """
                            <div class="metric-card">
                                <div class="metric-label">Output Classes</div>
                                <div class="metric-value">10 digits</div>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )

                else:
                    status_placeholder.markdown(
                        """
                        <div class="stage-box">
                            <span class="stage-done">✓ Image preprocessed</span><br>
                            <span class="stage-done">✓ 784 bytes transmitted</span><br>
                            <span class="stage-current">● Hardware timeout</span>
                        </div>
                        """,
                        unsafe_allow_html=True,
                    )

                    st.error(
                        "Hardware timeout. Check that the ESP32-S3 is connected "
                        "and the correct COM port is selected."
                    )

        except serial.SerialException:
            status_placeholder.markdown(
                """
                <div class="stage-box">
                    <span class="stage-current">● Serial connection failed</span>
                </div>
                """,
                unsafe_allow_html=True,
            )

            st.error(f"Cannot connect to {COM_PORT}.")
            st.warning(
                "Make sure the ESP32-S3 is connected and the Arduino IDE Serial "
                "Monitor is closed. Windows allows one program to use the COM port at a time."
            )


# ============================================================
# TECHNICAL OVERVIEW
# ============================================================
st.markdown("---")
st.markdown('<div class="section-title">Technical Overview</div>', unsafe_allow_html=True)

c1, c2, c3 = st.columns(3, gap="large")

with c1:
    st.markdown(
        """
        <div class="info-card">
            <div class="info-title">Edge AI Inference</div>
            <div class="info-text">
                The uploaded image is sent to the microcontroller.
                The neural network executes on the ESP32-S3 rather than
                using the PC to calculate the final digit.
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with c2:
    st.markdown(
        """
        <div class="info-card">
            <div class="info-title">Integer Neural Network</div>
            <div class="info-text">
                The model uses quantized integer data and a compact
                784 → 32 → 16 → 10 architecture for embedded inference.
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with c3:
    st.markdown(
        """
        <div class="info-card">
            <div class="info-title">Hardware-in-the-Loop</div>
            <div class="info-text">
                Streamlit provides the test interface while the ESP32-S3
                performs the actual inference and returns the predicted digit.
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )


# ============================================================
# SYSTEM PIPELINE
# ============================================================
st.markdown('<div class="section-title">Complete Data Path</div>', unsafe_allow_html=True)

st.markdown(
    """
    <div class="pipeline-box">
        <div class="pipeline-row">
            <span class="pipeline-node">Handwritten Image</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">Grayscale</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">28×28</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">784 Pixels</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">USB Serial</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">ESP32-S3</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">MLP</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">Argmax</span>
            <span class="pipeline-arrow">→</span>
            <span class="pipeline-node">Digit 0–9</span>
        </div>
    </div>
    """,
    unsafe_allow_html=True,
)


# ============================================================
# FOOTER
# ============================================================
st.markdown(
    """
    <div class="footer">
        ESP32-S3 Hardware AI • Handwritten Digit Recognition •
        FPGA-derived integer inference pipeline
    </div>
    """,
    unsafe_allow_html=True,
)
